variable "vpc_id" {}
variable "subnet_ids" {}
variable "security_groups" {}
variable "route_table_ids" {}

# see: https://docs.aws.amazon.com/ja_jp/AmazonECR/latest/userguide/vpc-endpoints.html

resource "aws_vpc_endpoint" "ecr-api" {
  service_name        = "com.amazonaws.ap-northeast-1.ecr.api"
  vpc_endpoint_type   = "Interface"
  vpc_id              = var.vpc_id
  subnet_ids          = var.subnet_ids
  security_group_ids  = var.security_groups
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecr-dkr" {
  service_name        = "com.amazonaws.ap-northeast-1.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  vpc_id              = var.vpc_id
  subnet_ids          = var.subnet_ids
  security_group_ids  = var.security_groups
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "logs" {
  service_name        = "com.amazonaws.ap-northeast-1.logs"
  vpc_endpoint_type   = "Interface"
  vpc_id              = var.vpc_id
  subnet_ids          = var.subnet_ids
  security_group_ids  = var.security_groups
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssm" {
  service_name        = "com.amazonaws.ap-northeast-1.ssm"
  vpc_endpoint_type   = "Interface"
  vpc_id              = var.vpc_id
  subnet_ids          = var.subnet_ids
  security_group_ids  = var.security_groups
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id          = var.vpc_id
  service_name    = "com.amazonaws.ap-northeast-1.s3"
  route_table_ids = var.route_table_ids
}

