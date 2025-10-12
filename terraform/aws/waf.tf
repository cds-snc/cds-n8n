#
# Load balancer WAF ACL
#
locals {
  excluded_common_rules = [
    "CrossSiteScripting_BODY", 
    "SizeRestrictions_BODY", 
    "SizeRestrictions_QUERYSTRING"
  ]
}

resource "aws_wafv2_web_acl" "n8n" {
  name  = "n8n_lb"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "InvalidHost"
    priority = 1

    action {
      block {}
    }

    statement {
      not_statement {
        statement {
          byte_match_statement {
            field_to_match {
              single_header {
                name = "host"
              }
            }
            text_transformation {
              priority = 1
              type     = "COMPRESS_WHITE_SPACE"
            }
            text_transformation {
              priority = 2
              type     = "LOWERCASE"
            }
            positional_constraint = "EXACTLY"
            search_string         = var.domain
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "InvalidHost"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "CanadaOnlyGeoRestriction"
    priority = 5

    action {
      block {
        custom_response {
          response_code = 403
          response_header {
            name  = "waf-block"
            value = "CanadaOnlyGeoRestriction"
          }
        }
      }
    }

    statement {
      not_statement {
        statement {
          geo_match_statement {
            country_codes = ["CA"]
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CanadaOnlyGeoRestriction"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 10

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesAmazonIpReputationList"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "RateLimitAllRequests"
    priority = 20

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 1000
        aggregate_key_type = "CUSTOM_KEYS"

        custom_key {
          ja4_fingerprint {
            fallback_behavior = "MATCH"
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitAllRequests"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "RateLimitMutatingRequests"
    priority = 30

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 200
        aggregate_key_type = "CUSTOM_KEYS"

        custom_key {
          ja4_fingerprint {
            fallback_behavior = "MATCH"
          }
        }

        scope_down_statement {
          regex_match_statement {
            field_to_match {
              method {}
            }
            regex_string = "^(delete|patch|post|put)$"
            text_transformation {
              priority = 1
              type     = "LOWERCASE"
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitMutatingRequests"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "RateLimitLogin"
    priority = 40

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 10
        aggregate_key_type = "CUSTOM_KEYS"

        custom_key {
          ja4_fingerprint {
            fallback_behavior = "MATCH"
          }
        }

        scope_down_statement {
          and_statement {
            statement {
              regex_match_statement {
                field_to_match {
                  method {}
                }
                regex_string = "^(put|post)$"
                text_transformation {
                  priority = 1
                  type     = "LOWERCASE"
                }
              }
            }
            statement {
              regex_match_statement {
                field_to_match {
                  uri_path {}
                }
                regex_string = "^/rest/(login|forgot-password)$"
                text_transformation {
                  priority = 1
                  type     = "LOWERCASE"
                }
              }
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitLogin"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 50
    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesLinuxRuleSet"
    priority = 60
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesLinuxRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 70

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        dynamic "rule_action_override" {
          for_each = local.excluded_common_rules
          content {
            name = rule_action_override.value
            action_to_use {
              count {}
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # Label match rule
  # Blocks requests that trigger `AWSManagedRulesCommonRuleSet#CrossSiteScripting_BODY` except those performing a partion workflow execution
  rule {
    name     = "WorkflowPartialExecutions"
    priority = 80

    action {
      block {}
    }

    statement {
      and_statement {
        statement {
          label_match_statement {
            scope = "LABEL"
            key   = "awswaf:managed:aws:core-rule-set:CrossSiteScripting_Body"
          }
        }
        statement {
          not_statement {
            statement {
              regex_pattern_set_reference_statement {
                field_to_match {
                  uri_path {}
                }
                arn = aws_wafv2_regex_pattern_set.workflow_partial_execution_paths.arn
                text_transformation {
                  type     = "LOWERCASE"
                  priority = 0
                }
              }
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "WorkflowPartialExecutions"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "n8n"
    sampled_requests_enabled   = true
  }

  tags = local.common_tags
}

resource "aws_wafv2_regex_pattern_set" "workflow_partial_execution_paths" {
  name        = "workflow_partial_execution_paths"
  description = "Paths that are related to partition workflow execution"
  scope       = "REGIONAL"

  regular_expression {
    regex_string = "^/rest/workflows/[a-zA-Z0-9]+/run.partial.*$"
  }
}

resource "aws_wafv2_web_acl_association" "n8n" {
  resource_arn = aws_lb.n8n.arn
  web_acl_arn  = aws_wafv2_web_acl.n8n.arn
}

#
# WAF logging
#
resource "aws_wafv2_web_acl_logging_configuration" "n8n_waf_logs" {
  log_destination_configs = [aws_kinesis_firehose_delivery_stream.n8n_waf_logs.arn]
  resource_arn            = aws_wafv2_web_acl.n8n.arn
}

resource "aws_kinesis_firehose_delivery_stream" "n8n_waf_logs" {
  name        = "aws-waf-logs-n8n"
  destination = "extended_s3"

  server_side_encryption {
    enabled = true
  }

  extended_s3_configuration {
    role_arn           = aws_iam_role.n8n_waf_logs.arn
    prefix             = "waf_acl_logs/AWSLogs/${var.account_id}/"
    bucket_arn         = local.cbs_satellite_bucket_arn
    compression_format = "GZIP"
  }
}

#
# WAF logging IAM role
#
resource "aws_iam_role" "n8n_waf_logs" {
  name               = "n8n-waf-logs"
  assume_role_policy = data.aws_iam_policy_document.n8n_waf_logs_assume.json
}

resource "aws_iam_role_policy" "n8n_waf_logs" {
  name   = "n8n-waf-logs"
  role   = aws_iam_role.n8n_waf_logs.id
  policy = data.aws_iam_policy_document.n8n_waf_logs.json
}

data "aws_iam_policy_document" "n8n_waf_logs_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "n8n_waf_logs" {
  statement {
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject"
    ]
    resources = [
      local.cbs_satellite_bucket_arn,
      "${local.cbs_satellite_bucket_arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:CreateServiceLinkedRole"
    ]
    resources = [
      "arn:aws:iam::*:role/aws-service-role/wafv2.amazonaws.com/AWSServiceRoleForWAFV2Logging"
    ]
  }
}

#
# AWS Shield Advanced
#
resource "aws_shield_subscription" "n8n" {
  auto_renew = "ENABLED"
}

resource "aws_shield_protection" "n8n_alb" {
  name         = "n8n-alb"
  resource_arn = aws_lb.n8n.arn
  tags         = local.common_tags
}

resource "aws_shield_protection" "n8n_route53" {
  name         = "n8n-route53"
  resource_arn = aws_route53_zone.n8n.arn
  tags         = local.common_tags
}

resource "aws_shield_application_layer_automatic_response" "n8n_alb" {
  resource_arn = aws_lb.n8n.arn
  action       = "BLOCK"
}
