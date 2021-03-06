resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.default.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.route53_cerificate_arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "nuxt" {
  listener_arn = aws_lb_listener.https.arn
  # listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nuxt.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_lb_listener_rule" "health_check" {
  listener_arn = aws_lb_listener.https.arn
  # listener_arn = aws_lb_listener.http.arn
  priority     = 90

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }

  condition {
    path_pattern {
      values = ["/health_check"]
    }
  }
}

resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.https.arn
  # listener_arn = aws_lb_listener.http.arn
  priority     = 80

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

resource "aws_lb_listener_rule" "admin" {
  listener_arn = aws_lb_listener.https.arn
  # listener_arn = aws_lb_listener.http.arn
  priority     = 70

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }

  condition {
    path_pattern {
      values = ["/admin*", "/assets*", "/packs*"]
    }
  }
}

# blue/green 設定
# resource "aws_lb_listener_rule" "default" {
#   # listener_arn = aws_lb_listener.https.arn
#   listener_arn = aws_lb_listener.http.arn
#   priority     = 100

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.blue.arn
#   }

#   lifecycle {
#     ignore_changes = [action] # blue/greenデプロイで、ターゲットグループとの紐付けが切り替わると必ず差分になってしまうのでignoreする
#   }

#   condition {
#     path_pattern {
#       values = ["/*"]
#     }
#   }
# }

resource "aws_lb_listener" "redirect_http_to_https" {
  load_balancer_arn = aws_lb.default.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

output "aws_lb_listener_https_arn" {
  value = aws_lb_listener.https.arn
}
