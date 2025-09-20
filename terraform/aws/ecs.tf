locals {
  container_env_n8n = [
    {
      "name"  = "EXTERNAL_FRONTEND_HOOKS_URLS",
      "value" = ""
    },
    {
      "name"  = "N8N_DIAGNOSTICS_CONFIG_FRONTEND"
      "value" = ""
    },
    {
      "name"  = "N8N_DIAGNOSTICS_CONFIG_BACKEND"
      "value" = ""
    },
    {
      "name"  = "N8N_DIAGNOSTICS_ENABLED"
      "value" = "false"
    },
    {
      "name"  = "N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS"
      "value" = "true"
    },
    {
      "name"  = "N8N_HIRING_BANNER_ENABLED"
      "value" = "false"
    },
    {
      "name"  = "N8N_HIDE_USAGE_PAGE"
      "value" = "true"
    },
    {
      "name"  = "N8N_HOST"
      "value" = var.domain
    },
    {
      "name"  = "N8N_LOG_LEVEL"
      "value" = "debug"
    },
    {
      "name"  = "N8N_PERSONALIZATION_ENABLED"
      "value" = "false"
    },
    {
      "name"  = "N8N_PORT"
      "value" = "5678"
    },
    {
      "name"  = "N8N_PROTOCOL"
      "value" = "http"
    },
    {
      "name"  = "N8N_PROXY_HOPS"
      "value" = "1"
    },
    {
      "name"  = "N8N_RUNNERS_ENABLED"
      "value" = "true"
    },
    {
      "name"  = "N8N_TEMPLATES_ENABLED"
      "value" = "false"
    },
    {
      "name"  = "NO_COLOR",
      "value" = "true"
    },
    {
      "name"  = "NODE_ENV"
      "value" = "production"
    },
    {
      "name"  = "QUEUE_HEALTH_CHECK_ACTIVE"
      "value" = "true"
    },
    {
      "name"  = "N8N_VERSION_CHECK_ENABLED"
      "value" = "false"
    },
    {
      "name"  = "WEBHOOK_URL"
      "value" = "https://${var.domain}/"
    }
  ]
  container_env_model = [
    {
      "name"  = "OLLAMA_HOST"
      "value" = "0.0.0.0"
    }
  ]
  container_secrets_n8n = [
    {
      "name"      = "N8N_ENCRYPTION_KEY"
      "valueFrom" = aws_ssm_parameter.n8n_encryption_key.arn
    },
  ]
}

module "n8n_ecs" {
  source = "github.com/cds-snc/terraform-modules//ecs?ref=v10.7.1"

  cluster_capacity_provider = "FARGATE_SPOT"
  cluster_name              = "n8n"
  service_name              = "n8n"
  cpu_architecture          = "ARM64"
  task_cpu                  = 1024
  task_memory               = 2048

  service_discovery_namespace_id = aws_service_discovery_private_dns_namespace.n8n.id
  service_discovery_enabled      = true
  service_use_latest_task_def    = true
  enable_autoscaling             = false

  # Task definition
  container_image                     = var.n8n_container_image
  container_host_port                 = 5678
  container_port                      = 5678
  container_environment               = local.container_env_n8n
  container_secrets                   = local.container_secrets_n8n
  container_read_only_root_filesystem = false

  task_exec_role_policy_documents = [
    data.aws_iam_policy_document.ecs_task_ssm_parameters.json
  ]

  task_role_policy_documents = [
    data.aws_iam_policy_document.efs_mount.json
  ]

  container_mount_points = [{
    sourceVolume  = "n8n-data"
    containerPath = "/home/node/.n8n"
    readOnly      = false
  }]

  task_volume = [{
    name = "n8n-data"
    efs_volume_configuration = {
      file_system_id          = aws_efs_file_system.n8n.id
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2049
      authorization_config = {
        access_point_id = aws_efs_access_point.n8n.id
        iam             = "ENABLED"
      }
    }
  }]

  # Networking
  lb_target_group_arn = aws_lb_target_group.n8n.arn
  subnet_ids          = module.vpc.private_subnet_ids
  security_group_ids  = [aws_security_group.n8n_ecs.id]

  billing_tag_value = var.billing_code
}

module "model_ecs" {
  count = 0 # Remove for now as the testing is complete

  source = "github.com/cds-snc/terraform-modules//ecs?ref=v10.7.1"

  create_cluster   = false
  cluster_name     = "n8n"
  service_name     = "model"
  cpu_architecture = "ARM64"
  task_cpu         = 4096
  task_memory      = 16384

  service_discovery_namespace_id = aws_service_discovery_private_dns_namespace.n8n.id
  service_discovery_enabled      = true
  service_use_latest_task_def    = true
  enable_autoscaling             = false
  enable_execute_command         = true

  task_role_policy_documents = [
    data.aws_iam_policy_document.ecs_task_create_tunnel.json
  ]

  # Task definition
  container_image                     = var.model_container_image
  container_host_port                 = 11434
  container_port                      = 11434
  container_environment               = local.container_env_model
  container_read_only_root_filesystem = false

  # Networking
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [aws_security_group.model_ecs.id]

  billing_tag_value = var.billing_code
}

#
# Service discovery namespace
#
resource "aws_service_discovery_private_dns_namespace" "n8n" {
  name        = "n8n.ecs.local"
  vpc         = module.vpc.vpc_id
  description = "Service discovery namespace for n8n"
}

#
# IAM policies
#
data "aws_iam_policy_document" "ecs_task_create_tunnel" {
  statement {
    sid    = "CreateSSMTunnel"
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ecs_task_ssm_parameters" {
  statement {
    sid    = "GetSSMParameters"
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
    ]
    resources = [
      aws_ssm_parameter.n8n_encryption_key.arn,
    ]
  }
}

data "aws_iam_policy_document" "efs_mount" {
  statement {
    effect = "Allow"
    actions = [
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:DescribeMountTargets",
    ]
    resources = [
      aws_efs_file_system.n8n.arn
    ]
  }
}

#
# SSM parameters
#
resource "aws_ssm_parameter" "n8n_encryption_key" {
  name  = "n8n_encryption_key"
  type  = "SecureString"
  value = var.n8n_encryption_key
  tags  = local.common_tags
}
