variable "cbs_satellite_bucket_name" {
  description = "The name of the CBS Satellite bucket for storing logs."
  type        = string
}

variable "cloudwatch_alert_slack_webhook" {
  description = "Slack webhook URL for CloudWatch alerts."
  type        = string
  sensitive   = true
}

variable "domain" {
  description = "The domain name for n8n."
  type        = string
}

variable "n8n_container_image" {
  description = "n8n's Docker image and tag."
  type        = string
}

variable "n8n_encryption_key" {
  description = "n8n's encryption key for securing credentials."
  type        = string
  sensitive   = true
}

variable "env" {
  description = "Environment name (e.g. prod, staging)."
  type        = string
}

variable "model_container_image" {
  description = "Model's Docker image and tag."
  type        = string
}

variable "region" {
  description = "AWS region."
  type        = string
  default     = "ca-central-1"
}

variable "account_id" {
  description = "AWS account ID."
  type        = string
}

variable "billing_code" {
  description = "Billing code tag value."
  type        = string
}

variable "product_name" {
  description = "(Required) The name of the product you are deploying."
  type        = string
}

variable "vector_db_username" {
  description = "Username for the Vector database."
  type        = string
  sensitive   = true
}

variable "vector_db_password" {
  description = "Password for the Vector database."
  type        = string
  sensitive   = true
}
