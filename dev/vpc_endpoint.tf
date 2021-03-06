module "vpce" {
  source     = "../modules/vpc_endpoint"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  security_groups = [
    module.allow_all_access_from_vpc.this_security_group_id,
  ]
  route_table_ids = module.vpc.private_route_table_ids
}
