locals {
  n8n_error_filters = [
    "ERROR",
    "Error",
    "error",
    "Exception",
    "exception",
  ]
  n8n_error_skip = [
    "Last session crashed",
    "Troubleshooting URL",
  ]
  n8n_error_metric_pattern = "[(w1=\"*${join("*\" || w1=\"*", local.n8n_error_filters)}*\") && w1!=\"*${join("*\" && w1!=\"*", local.n8n_error_skip)}*\"]"
}

#
# ECS resource use
#
resource "aws_cloudwatch_metric_alarm" "n8n_ecs_high_cpu" {
  alarm_name          = "ecs-high-cpu"
  alarm_description   = "High CPU use over 5 minutes."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "5"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = 50
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.cloudwatch_alert_warning.arn]
  ok_actions    = [aws_sns_topic.cloudwatch_alert_ok.arn]

  dimensions = {
    ClusterName = module.n8n_ecs.cluster_name
    ServiceName = module.n8n_ecs.service_name
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "n8n_ecs_high_memory" {
  alarm_name          = "ecs-high-memory"
  alarm_description   = "High memory use over 5 minutes."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "5"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = 50
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.cloudwatch_alert_warning.arn]
  ok_actions    = [aws_sns_topic.cloudwatch_alert_ok.arn]

  dimensions = {
    ClusterName = module.n8n_ecs.cluster_name
    ServiceName = module.n8n_ecs.service_name
  }

  tags = local.common_tags
}

#
# Load balancer
#
resource "aws_cloudwatch_metric_alarm" "n8n_load_balancer_unhealthy_hosts" {
  alarm_name          = "load-balancer-unhealthy-hosts"
  alarm_description   = "There are unhealthy n8n load balancer hosts in a 1 minute period."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = "1"
  evaluation_periods  = "1"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Maximum"
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.cloudwatch_alert_warning.arn]
  ok_actions    = [aws_sns_topic.cloudwatch_alert_ok.arn]

  dimensions = {
    LoadBalancer = aws_lb.n8n.arn_suffix
    TargetGroup  = aws_lb_target_group.n8n.arn_suffix
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "n8n_load_balancer_healthy_hosts" {
  alarm_name          = "load-balancer-healthy-hosts"
  alarm_description   = "There are no healthy hosts for the n8n load balancer in a 1 minute period."
  comparison_operator = "LessThanThreshold"
  threshold           = "1"
  evaluation_periods  = "1"
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Maximum"
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.cloudwatch_alert_warning.arn]
  ok_actions    = [aws_sns_topic.cloudwatch_alert_ok.arn]

  dimensions = {
    LoadBalancer = aws_lb.n8n.arn_suffix
    TargetGroup  = aws_lb_target_group.n8n.arn_suffix
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "n8n_load_balancer_response_time" {
  alarm_name          = "load-balancer-response-time"
  alarm_description   = "Response time for the n8n load balancer is consistently over 3 seconds over 5 minutes."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "5"
  datapoints_to_alarm = "4"
  threshold           = 3
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.cloudwatch_alert_warning.arn]
  ok_actions    = [aws_sns_topic.cloudwatch_alert_ok.arn]

  metric_query {
    id          = "response_time"
    return_data = "true"
    metric {
      metric_name = "TargetResponseTime"
      namespace   = "AWS/ApplicationELB"
      period      = "60"
      stat        = "Average"
      dimensions = {
        LoadBalancer = aws_lb.n8n.arn_suffix
        TargetGroup  = aws_lb_target_group.n8n.arn_suffix
      }
    }
  }

  tags = local.common_tags
}

#
# Errors logged
#
resource "aws_cloudwatch_log_metric_filter" "n8n_ecs_errors" {
  name           = "n8n-error"
  pattern        = local.n8n_error_metric_pattern
  log_group_name = module.n8n_ecs.cloudwatch_log_group_name

  metric_transformation {
    name          = "n8n-error"
    namespace     = "n8n"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "n8n_ecs_errors" {
  alarm_name          = "n8n-errors"
  alarm_description   = "n8n errors logged over 1 minute."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.n8n_ecs_errors.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.n8n_ecs_errors.metric_transformation[0].namespace
  period              = "60"
  statistic           = "Sum"
  threshold           = "0"
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.cloudwatch_alert_warning.arn]
  ok_actions    = [aws_sns_topic.cloudwatch_alert_ok.arn]

  tags = local.common_tags
}

#
# Log Insight queries
#
resource "aws_cloudwatch_query_definition" "n8n_ecs_errors" {
  name = "n8n - errors"

  log_group_names = [module.n8n_ecs.cloudwatch_log_group_name]

  query_string = <<-QUERY
    fields @timestamp, @message, @logStream
    | filter @message like /${join("|", local.n8n_error_filters)}/
    | sort @timestamp desc
    | limit 100
  QUERY
}