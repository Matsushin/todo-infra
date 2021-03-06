module "rds" {
  source                 = "../modules/rds"
  name                   = "${var.project_name}-${var.env}-rds"
  instance_class         = "db.t3.small"
  db_name                = "todo_dev"
  username               = "todoadmin"
  subnets                = module.vpc.private_subnets
  vpc_security_group_ids = [module.mysql_sg.this_security_group_id]
}
