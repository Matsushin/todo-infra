module "http_sg" {
  source              = "terraform-aws-modules/security-group/aws//modules/http-80"
  name                = "${var.project_name}-${var.env}-http-sg"
  description         = "Security group for HTTP ports open within VPC"
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
}

module "https_sg" {
  source              = "terraform-aws-modules/security-group/aws//modules/https-443"
  name                = "${var.project_name}-${var.env}-https-sg"
  description         = "Security group for HTTPS ports open within VPC"
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
}

module "front_sg" {
  source              = "terraform-aws-modules/security-group/aws//modules/http-80"
  name                = "${var.project_name}-${var.env}-front-sg"
  description         = "Security group for front with HTTP ports open within VPC"
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = module.vpc.public_subnets_cidr_blocks
}

module "backend_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  name        = "${var.project_name}-${var.env}-backend-sg"
  description = "Security group for backend with Rails ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      cidr_blocks = join(",", module.vpc.public_subnets_cidr_blocks)
    }
  ]
  ingress_with_self = [
    { rule = "all-all" }
  ]
  egress_rules = ["all-all"]
}

module "mysql_sg" {
  source              = "terraform-aws-modules/security-group/aws//modules/mysql"
  name                = "${var.project_name}-${var.env}-mysql-sg"
  description         = "Security group for MySQL ports open within VPC"
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = module.vpc.private_subnets_cidr_blocks
}

module "allow_all_access_from_vpc" {
  source      = "terraform-aws-modules/security-group/aws"
  name        = "${var.project_name}-${var.env}-allow-all-access-from-vpc-sg"
  description = "Allow all access inside VPC"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule        = "all-tcp"
      cidr_blocks = module.vpc.vpc_cidr_block
    }
  ]
}
