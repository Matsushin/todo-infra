variable "bucket_name" {}
variable "force_destroy" {}
variable "lifecycle_rule_enabled" {
  default = false
}
variable "acl" {
  default = "private"
}
variable "cors_rules" {
  type = set(object(
    {
      allowed_headers = list(string)
      allowed_methods = list(string)
      allowed_origins = list(string)
      expose_headers  = list(string)
      max_age_seconds = number
    }
  ))
  default = []
}
variable "block_public_acls" {
  default = true
}
variable "block_public_policy" {
  default = true
}
variable "ignore_public_acls" {
  default = true
}
variable "restrict_public_buckets" {
  default = true
}

data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket" "default" {
  bucket        = var.bucket_name
  acl           = var.acl
  force_destroy = var.force_destroy

  lifecycle_rule {
    enabled = var.lifecycle_rule_enabled

    expiration {
      days = "180"
    }
  }

  dynamic "cors_rule" {
    for_each = var.cors_rules
    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }
}

resource "aws_s3_bucket_policy" "default" {
  bucket = aws_s3_bucket.default.id
  policy = data.aws_iam_policy_document.default.json
}

data "aws_iam_policy_document" "default" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.default.id}/*"]

    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }
  }
}

resource "aws_s3_bucket_public_access_block" "default" {
  bucket                  = aws_s3_bucket.default.id
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

output "bucket_id" {
  value = aws_s3_bucket.default.id
}

output "bucket_arn" {
  value = aws_s3_bucket.default.arn
}

output "bucket_regional_domain_name" {
  value = aws_s3_bucket.default.bucket_regional_domain_name
}
