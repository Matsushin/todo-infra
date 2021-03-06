module "s3_resource" {
  source             = "../modules/s3"
  bucket_name        = var.resource_bucket_name
  force_destroy      = false
  block_public_acls  = false
  ignore_public_acls = false
  cors_rules = [{
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST", "PUT"]
    allowed_origins = ["https://${var.domain_name}"]
    max_age_seconds = 300
    expose_headers  = []
  }]
}

module "s3_log" {
  source                 = "../modules/s3"
  bucket_name            = var.log_bucket_name
  force_destroy          = false
  lifecycle_rule_enabled = true
}
