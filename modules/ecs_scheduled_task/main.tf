variable "name" {}
variable "container_definitions" {}
# variable "container_name" {}
# variable "task_definition_arn" {}
variable "cluster" {}
variable "role_arn" {}
variable "security_groups" {}
variable "lb_depends_on" {}
variable "subnets" {}
variable "execution_role_arn" {}
variable "task_role_arn" {}
variable "cpu" {
  default = "256"
}
variable "memory" {
  default = "512"
}

resource "aws_ecs_task_definition" "default" {
  family                   = "td-${var.name}"
  cpu                      = var.cpu
  memory                   = var.memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = var.container_definitions
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
}

resource "aws_cloudwatch_event_rule" "batch_sample" {
  name                = "batch-sample"
  schedule_expression = "cron(*/5 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "batch_sample" {
  target_id = "batch-sample"
  arn       = var.cluster.arn
  rule      = aws_cloudwatch_event_rule.batch_sample.name
  role_arn  = var.role_arn

  ecs_target {
    launch_type         = "FARGATE"
    task_count          = 1
    platform_version    = "1.4.0"
    task_definition_arn = aws_ecs_task_definition.default.arn

    network_configuration {
      assign_public_ip = false
      security_groups  = var.security_groups
      subnets          = var.subnets
    }
  }

  input = <<DOC
{
  "containerOverrides": [
    {
      "name": "batch",
      "command": ["bundle", "exec", "rake", "batch_sample:run"]
    }
  ]
}
DOC
}

# resource "aws_cloudwatch_event_rule" "check_fax_result" {
#   name                = "check-fax-result"
#   schedule_expression = "cron(*/5 * * * ? *)"
# }

# resource "aws_cloudwatch_event_target" "check_fax_result" {
#   target_id = "check-fax-result"
#   arn       = var.cluster.arn
#   rule      = aws_cloudwatch_event_rule.check_fax_result.name
#   role_arn  = var.role_arn
#
#   ecs_target {
#     launch_type         = "FARGATE"
#     task_count          = 1
#     platform_version    = "1.4.0"
#     task_definition_arn = aws_ecs_task_definition.default.arn
#
#     network_configuration {
#       assign_public_ip = false
#       security_groups  = var.security_groups
#       subnets          = var.subnets
#     }
#   }
#
#   input = <<DOC
# {
#   "containerOverrides": [
#     {
#       "name": "batch",
#       "command": ["bundle", "exec", "rake", "check_fax_result:run"]
#     }
#   ]
# }
# DOC
# }

# resource "aws_cloudwatch_event_rule" "send_supplier_user_confirmation_mail" {
#   name                = "send-supplier-user-confirmation-mail"
#   schedule_expression = "cron(0 23 * * ? *)" # UTC時間。JSTでいう08:00
# }

# resource "aws_cloudwatch_event_target" "send_supplier_user_confirmation_mail" {
#   target_id = "send-supplier-user-confirmation-mail"
#   arn       = var.cluster.arn
#   rule      = aws_cloudwatch_event_rule.send_supplier_user_confirmation_mail.name
#   role_arn  = var.role_arn
#
#   ecs_target {
#     launch_type         = "FARGATE"
#     task_count          = 1
#     platform_version    = "1.4.0"
#     task_definition_arn = aws_ecs_task_definition.default.arn
#
#     network_configuration {
#       assign_public_ip = false
#       security_groups  = var.security_groups
#       subnets          = var.subnets
#     }
#   }
#
#   input = <<DOC
# {
#   "containerOverrides": [
#     {
#       "name": "batch",
#       "command": ["bundle", "exec", "rake", "send_supplier_user_confirmation_mail:run"]
#     }
#   ]
# }
# DOC
# }

# resource "aws_cloudwatch_event_rule" "refresh_material_keywords" {
#   name                = "refresh_material_keywords"
#   schedule_expression = "cron(0 17 * * ? *)" # UTC時間。JSTでいう02:00
# }
#
# resource "aws_cloudwatch_event_target" "refresh_material_keywords" {
#   depends_on = [var.lb_depends_on, aws_ecs_task_definition.default]
#   target_id  = "refresh_material_keywords"
#   arn        = var.cluster.arn
#   rule       = aws_cloudwatch_event_rule.refresh_material_keywords.name
#   role_arn   = var.role_arn
#
#   ecs_target {
#     launch_type         = "FARGATE"
#     task_count          = 1
#     platform_version    = "1.4.0"
#     task_definition_arn = aws_ecs_task_definition.default.arn
#
#     network_configuration {
#       assign_public_ip = false
#       security_groups  = var.security_groups
#       subnets          = var.subnets
#     }
#   }
#
#   input = <<DOC
# {
#   "containerOverrides": [
#     {
#       "name": "batch",
#       "command": ["bundle", "exec", "rake", "refresh_material_keywords"]
#     }
#   ]
# }
# DOC
# }
