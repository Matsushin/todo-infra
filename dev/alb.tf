module "alb" {
  source                     = "../modules/alb"
  s3_log_depends_on          = ["module.s3_log.name"]
  vpc_id                     = module.vpc.vpc_id
  name                       = "${var.project_name}-${var.env}-alb"
  subnets                    = module.vpc.public_subnets
  enable_deletion_protection = false
  log_bucket_id              = module.s3_log.bucket_id

  security_group_ids = [
    module.http_sg.this_security_group_id,
    module.https_sg.this_security_group_id
  ]

  route53_cerificate_arn = data.aws_acm_certificate.default.arn
}
