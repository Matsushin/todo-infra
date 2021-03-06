variable "vpc_id" {}
variable "name" {}
variable "subnets" {}
variable "enable_deletion_protection" {}
variable "log_bucket_id" {}
variable "security_group_ids" {}

variable "route53_cerificate_arn" {}
variable "s3_log_depends_on" {}

variable "nuxt_healthcheck_port" {
  default = 401
}

resource "aws_lb" "default" {
  depends_on                 = [var.s3_log_depends_on]
  name                       = var.name
  load_balancer_type         = "application"
  internal                   = false
  idle_timeout               = 60
  enable_deletion_protection = var.enable_deletion_protection

  subnets = var.subnets

  access_logs {
    bucket  = var.log_bucket_id
    prefix  = var.name
    enabled = true
  }

  security_groups = var.security_group_ids
}

output "alb_dns_name" {
  value = aws_lb.default.dns_name
}

output "zone_id" {
  value = aws_lb.default.zone_id
}
