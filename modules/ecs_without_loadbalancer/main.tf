variable "name" {}
variable "container_definitions" {}
variable "security_groups" {}
variable "subnets" {}
variable "execution_role_arn" {}
variable "cluster_arn" {}

resource "aws_ecs_task_definition" "default" {
  family = var.name
  cpu = "256"
  memory = "512"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions = var.container_definitions
  execution_role_arn = var.execution_role_arn
}

resource "aws_ecs_service" "default" {

  depends_on = ["aws_ecs_task_definition.default"]

  name = var.name
  cluster = var.cluster_arn
  task_definition = aws_ecs_task_definition.default.arn
  launch_type = "FARGATE"
  platform_version = "1.3.0"

  network_configuration {
    assign_public_ip = true # ECRからimageをPullするため
    security_groups = var.security_groups
    subnets = var.subnets
  }

  lifecycle {
    ignore_changes = ["task_definition"]
  }
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.default.arn
}

