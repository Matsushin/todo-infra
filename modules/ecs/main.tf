variable "name" {}
variable "container_definitions" {}
variable "security_groups" {}
variable "subnets" {}
variable "execution_role_arn" {}
variable "cluster_arn" {}
variable "container_name" {}
variable "container_port" {}
variable "lb_target_group_arn" {}
variable "lb_depends_on" {}
variable "desired_count" {}

resource "aws_ecs_task_definition" "default" {
  family                   = var.name
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = var.container_definitions
  execution_role_arn       = var.execution_role_arn
}

resource "aws_ecs_service" "default" {

  depends_on = ["var.lb_depends_on", "aws_ecs_task_definition.default"]

  name                              = var.name
  cluster                           = var.cluster_arn
  task_definition                   = aws_ecs_task_definition.default.arn
  desired_count                     = var.desired_count
  launch_type                       = "FARGATE"
  platform_version                  = "1.4.0"
  health_check_grace_period_seconds = 60

  network_configuration {
    assign_public_ip = true
    security_groups  = var.security_groups
    subnets          = var.subnets
  }

  load_balancer {
    target_group_arn = var.lb_target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  scheduling_strategy = "REPLICA"

  lifecycle {
    ignore_changes = [
      "desired_count",
      "task_definition",
      "load_balancer",
    ]
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }
}

output "aws_ecs_service_name" {
  value = aws_ecs_service.default.name
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.default.arn
}

