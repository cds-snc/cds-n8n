locals {
  availability_zone_count = 2
  common_tags = {
    Terraform  = "true"
    CostCentre = var.billing_code
  }
}