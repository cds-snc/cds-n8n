module "vector_db" {
  source = "github.com/cds-snc/terraform-modules//rds?ref=v10.8.4"
  name   = "vector-${var.env}"

  database_name  = "vector"
  engine         = "aurora-postgresql"
  engine_version = "16.8"
  instances      = 1
  instance_class = "db.serverless"
  username       = var.vector_db_username
  password       = var.vector_db_password
  use_proxy      = false

  backup_retention_period      = 2
  preferred_backup_window      = "02:00-04:00"
  performance_insights_enabled = false

  serverless_min_capacity = 0
  serverless_max_capacity = 1

  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [aws_security_group.vector_db.id]

  billing_tag_value = var.billing_code
}
