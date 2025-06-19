locals {
  cbs_satellite_bucket_arn = "arn:aws:s3:::${var.cbs_satellite_bucket_name}"
  availability_zone_count  = 2
  common_tags = {
    Terraform  = "true"
    CostCentre = var.billing_code
  }
}