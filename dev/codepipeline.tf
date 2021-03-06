module "codepipeline" {
  source                         = "../modules/codepipeline"
  backend_codepipeline_name      = "${var.backend_repo_name}-${var.env}"
  front_codepipeline_name        = "${var.front_repo_name}-${var.env}"
  env                            = var.env
  github_organization            = "Matsushin"
  backend_github_repository_name = var.backend_repo_name
  backend_github_branch          = "deploy/dev"
  front_github_repository_name   = var.front_repo_name
  front_github_branch            = "deploy/dev"
  artifact_bucket_name           = "${var.project_name}-${var.env}-codepipeline-artifact"
  ecs_cluster_name               = module.ecs.cluster.name
  ecs_service_backend_name       = module.svc-backend.service_name
  ecs_service_front_name         = module.svc-front.service_name
  project_name                   = var.project_name
  artifact_bucket_force_destroy  = true
  github_token                   = data.aws_ssm_parameter.github_token.value
  aws_account_id                 = data.aws_caller_identity.current.account_id
  # front_bucket_name              = var.front_bucket_name
  # distribution_id                = module.frontend.aws_cloudfront_distribution_id
  # api_base_url                   = "http://${module.alb.alb_dns_name}"
}
