locals {
  container_env = [
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
      "name"  = "NODE_ENV"
      "value" = "production"
    },
    {
      "name"  = "WEBHOOK_URL"
      "value" = "https://${var.domain}/"
    }
  ]
  container_secrets = [
    {
      "name"      = "N8N_ENCRYPTION_KEY"
      "valueFrom" = aws_ssm_parameter.n8n_encryption_key.arn
    },
  ]
}

module "n8n_ecs" {
  source = "github.com/cds-snc/terraform-modules//ecs?ref=v10.5.2"

  cluster_name              = "n8n"
  service_name              = "n8n"
  task_cpu                  = 1024
  task_memory               = 2048
  cluster_capacity_provider = "FARGATE_SPOT"
  cpu_architecture          = "arm64"

  service_use_latest_task_def = true
  enable_autoscaling          = false

  # Task definition
  container_image                     = var.n8n_container_image
  container_host_port                 = 5678
  container_port                      = 5678
  container_environment               = local.container_env
  container_secrets                   = local.container_secrets
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

#
# IAM policies
#
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

#
# Shutdown during off hours
#
module "ecs_shutdown" {
  source = "github.com/cds-snc/terraform-modules//schedule_shutdown?ref=v10.5.2"

  ecs_service_arns = [
    "arn:aws:ecs:${var.region}:${var.account_id}:service/${module.n8n_ecs.cluster_name}/${module.n8n_ecs.service_name}"
  ]

  schedule_shutdown = "cron(0 22 * * ? *)"       # 10pm UTC, every day
  schedule_startup  = "cron(0 12 ? * MON-FRI *)" # 12pm UTC, Monday-Friday

  billing_tag_value = var.billing_code
}
