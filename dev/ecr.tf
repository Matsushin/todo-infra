module "ecr-front" {
  source          = "../modules/ecr"
  repository_name = "${var.project_name}-front"
}

module "ecr-backend" {
  source          = "../modules/ecr"
  repository_name = "${var.project_name}-backend"
}