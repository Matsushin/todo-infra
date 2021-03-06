variable "project_name" {
  default = "todo"
}

variable "env" {
  default = "dev"
}

variable "domain_name" {
  default = "matsushin-dev.com"
}

variable "resource_bucket_name" {
  default = "todo-dev-resource"
}

variable "log_bucket_name" {
  default = "todo-dev-log"
}

variable "front_bucket_name" {
  default = "todo-dev-front"
}

variable "front_repo_name" {
  default = "todo-front"
}

variable "backend_repo_name" {
  default = "todo-back"
}

variable "ecr_aws_account_id" {
  default = "477438465448"
}

data "aws_ssm_parameter" "github_token" {
  name = "/dev/build/github_token"
}

data "aws_acm_certificate" "default" {
  domain = var.domain_name
}

data "aws_route53_zone" "default" {
  name = "matsushin-dev.com"
}