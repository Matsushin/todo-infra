module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.project_name}-${var.env}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = var.env
  }

  # PrivateLink 有効化のために必要
  enable_dns_hostnames = true
  enable_dns_support   = true
}

module "flow_log" {
  source = "../modules/flow_log"
  name   = "${var.project_name}-${var.env}-vpc-flow-log"
  vpc_id = module.vpc.vpc_id
}
