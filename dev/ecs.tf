module "front" {
  source         = "../modules/container_definition"
  name           = "front"
  env            = var.env
  aws_account_id = var.ecr_aws_account_id
  project_name   = var.project_name
  container_name = "front"
}

module "backend" {
  source         = "../modules/container_definition"
  name           = "backend"
  env            = var.env
  aws_account_id = var.ecr_aws_account_id
  project_name   = var.project_name
  container_name = "backend"
}

module "batch" {
  source         = "../modules/container_definition"
  name           = "backend"
  env            = var.env
  aws_account_id = var.ecr_aws_account_id
  project_name   = var.project_name
  container_name = "batch"
}

module "ecs" {
  source = "../modules/ecs_cluster"
  name   = "${var.project_name}-${var.env}-ecs"
}

module "svc-front" {
  source                = "../modules/ecs_service"
  lb_depends_on         = [module.ecs.cluster]
  cluster               = module.ecs.cluster
  name                  = "${var.project_name}-${var.env}-front"
  container_definitions = "[${module.front.rendered}]"
  container_name        = "front"
  container_port        = "80"
  security_groups       = [module.front_sg.this_security_group_id]
  subnets               = module.vpc.private_subnets

  lb_target_group_arn = module.alb.aws_lb_target_group_nuxt.arn
  execution_role_arn  = module.ecs_task_execution_role.iam_role_arn
  task_role_arn       = module.ecs_task_role.iam_role_arn
}

module "svc-backend" {
  source                = "../modules/ecs_service"
  lb_depends_on         = [module.ecs.cluster]
  cluster               = module.ecs.cluster
  name                  = "${var.project_name}-${var.env}-backend"
  container_definitions = "[${module.backend.rendered}]"
  container_name        = "backend"
  container_port        = "3000"
  security_groups       = [module.backend_sg.this_security_group_id]
  subnets               = module.vpc.private_subnets
  cpu                   = "512"
  memory                = "2048"

  #   lb_target_group_arn = module.alb.aws_lb_target_group_blue.arn
  lb_target_group_arn = module.alb.aws_lb_target_group_api.arn
  execution_role_arn  = module.ecs_task_execution_role.iam_role_arn
  task_role_arn       = module.ecs_task_role.iam_role_arn
}

module "scheduled_task" {
  source                = "../modules/ecs_scheduled_task"
  lb_depends_on         = [module.ecs.cluster]
  cluster               = module.ecs.cluster
  name                  = "${var.project_name}-${var.env}-batch"
  container_definitions = "[${module.batch.rendered}]"
  security_groups       = [module.backend_sg.this_security_group_id]
  subnets               = module.vpc.private_subnets
  cpu                   = "512"
  memory                = "2048"
  role_arn              = module.ecs_events_role.iam_role_arn

  execution_role_arn = module.ecs_task_execution_role.iam_role_arn
  task_role_arn      = module.ecs_task_role.iam_role_arn
}

module "ecs_task_execution_role" {
  source     = "../modules/iam_role"
  name       = "${var.project_name}-${var.env}-ecs-task-execution"
  identifier = "ecs-tasks.amazonaws.com"
  policy     = data.aws_iam_policy_document.ecs_task_execution.json
}

module "ecs_task_role" {
  source     = "../modules/iam_role"
  name       = "${var.project_name}-${var.env}-ecs-task"
  identifier = "ecs-tasks.amazonaws.com"
  policy     = data.aws_iam_policy_document.ecs_task.json
}

data "aws_iam_policy" "ecs_task_execution_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_task_execution" {
  source_json = data.aws_iam_policy.ecs_task_execution_role_policy.policy

  # TODO: ssm,kmsの権限は絞る
  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameters", "kms:Decrypt"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ecs_task" {
  statement {
    effect    = "Allow"
    actions   = ["s3:List*"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    # actions   = ["s3:GetObject", "s3:PutObject"]
    actions   = ["s3:*"]
    resources = ["${module.s3_resource.bucket_arn}/*"]
  }
}

module "ecs_events_role" {
  source     = "../modules/iam_role"
  name       = "${var.project_name}-${var.env}-ecs-events"
  identifier = "events.amazonaws.com"
  policy     = data.aws_iam_policy.ecs_events_role_policy.policy
}

data "aws_iam_policy" "ecs_events_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
}

resource "aws_cloudwatch_log_group" "for_ecs_dx_demo_api" {
  name              = "/ecs/${var.project_name}-${var.env}-ecs"
  retention_in_days = 90
}
