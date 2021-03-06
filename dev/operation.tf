module "operation" {
  source         = "../modules/operation"
  subnet_ids     = module.vpc.private_subnets
  env            = var.env
  aws_account_id = data.aws_caller_identity.current.account_id
  project_name   = var.project_name
}
