resource "aws_lb_target_group" "nuxt" {
  name                 = "${var.name}-tg-front"
  target_type          = "ip"
  vpc_id               = var.vpc_id
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = 60

  health_check {
    path                = "/"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = var.nuxt_healthcheck_port
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  depends_on = [aws_lb.default]
}

resource "aws_lb_target_group" "api" {
  name                 = "${var.name}-tg-backend"
  target_type          = "ip"
  vpc_id               = var.vpc_id
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = 60

  health_check {
    path                = "/health_check"
    healthy_threshold   = 5
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 30
    matcher             = 200
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  depends_on = [aws_lb.default]
}

# blue/green 設定
# resource "aws_lb_target_group" "blue" {
#   name                 = "${var.name}-tg-api-blue"
#   target_type          = "ip"
#   vpc_id               = var.vpc_id
#   port                 = 80
#   protocol             = "HTTP"
#   deregistration_delay = 300
#
#   health_check {
#     path                = "/health_check"
#     healthy_threshold   = 5
#     unhealthy_threshold = 10
#     timeout             = 5
#     interval            = 30
#     matcher             = 200
#     port                = "traffic-port"
#     protocol            = "HTTP"
#   }
#
#   depends_on = [aws_lb.default]
# }
#
# resource "aws_lb_target_group" "green" {
#   name                 = "${var.name}-tg-api-green"
#   target_type          = "ip"
#   vpc_id               = var.vpc_id
#   port                 = 80
#   protocol             = "HTTP"
#   deregistration_delay = 300
#
#   health_check {
#     path                = "/health_check"
#     healthy_threshold   = 5
#     unhealthy_threshold = 10
#     timeout             = 5
#     interval            = 30
#     matcher             = 200
#     port                = "traffic-port"
#     protocol            = "HTTP"
#   }
#
#   depends_on = [aws_lb.default]
# }

output "aws_lb_target_group_nuxt" {
  value = aws_lb_target_group.nuxt
}

output "aws_lb_target_group_api" {
  value = aws_lb_target_group.api
}

# output "aws_lb_target_group_blue" {
#   value = aws_lb_target_group.blue
# }

# output "aws_lb_target_group_green" {
#   value = aws_lb_target_group.green
# }
