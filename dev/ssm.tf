resource "aws_ssm_parameter" "nuxt_host" {
  name  = "/${var.env}/nuxt/host"
  value = "0.0.0.0"
  type  = "String"
}

resource "aws_ssm_parameter" "nuxt_port" {
  name  = "/${var.env}/nuxt/port"
  value = "80"
  type  = "String"
}

resource "aws_ssm_parameter" "nuxt_api_base_url" {
  name  = "/${var.env}/nuxt/api_base_url"
  value = "uninitialized"
  type  = "String"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "nuxt_basic_auth_name" {
  name  = "/${var.env}/nuxt/basic_auth_name"
  value = "admin"
  type  = "String"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "nuxt_basic_auth_pass" {
  name  = "/${var.env}/nuxt/basic_auth_password"
  value = "uninitialized"
  type  = "SecureString"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "nuxt_basic_auth_enabled" {
  name  = "/${var.env}/nuxt/basic_auth_enabled"
  value = "true"
  type  = "String"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "db_host" {
  name  = "/${var.env}/db/host"
  value = "uninitialized"
  type  = "String"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "db_name" {
  name  = "/${var.env}/db/name"
  value = "todo_dev"
  type  = "String"
}

resource "aws_ssm_parameter" "db_username" {
  name  = "/${var.env}/db/username"
  value = "todoadmin"
  type  = "String"
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/${var.env}/db/password"
  value = "uninitialized"
  type  = "SecureString"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "rails_secret_key" {
  name  = "/${var.env}/rails/secret_key"
  value = "uninitialized"
  type  = "SecureString"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "s3_resource_bucket" {
  name  = "/${var.env}/s3/resource_bucket"
  value = var.resource_bucket_name
  type  = "String"
}

resource "aws_ssm_parameter" "admin_basic_auth_name" {
  name  = "/${var.env}/rails/basic_auth_name"
  value = "admin"
  type  = "String"
}

resource "aws_ssm_parameter" "admin_basic_auth_password" {
  name  = "/${var.env}/rails/basic_auth_password"
  value = "uninitialized"
  type  = "SecureString"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "mailer_sender" {
  name  = "/${var.env}/rails/mailer_sender"
  value = "noreply@dev-todo.matsushin.tech"
  type  = "String"
}

resource "aws_ssm_parameter" "sendgrid_api_key" {
  name  = "/${var.env}/rails/sendgrid_api_key"
  value = "uninitialized"
  type  = "SecureString"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "front_base_url" {
  name  = "/${var.env}/rails/front_base_url"
  value = "uninitialized"
  type  = "String"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "rails_public_base_url" {
  name  = "/${var.env}/rails/public_base_url"
  value = "http://localhost:3000/"
  type  = "String"
}

resource "aws_ssm_parameter" "dockerhub_username" {
  name  = "/${var.env}/build/dockerhub_username"
  value = "uninitialized"
  type  = "SecureString"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "dockerhub_password" {
  name  = "/${var.env}/build/dockerhub_password"
  value = "uninitialized"
  type  = "SecureString"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "emails_for_failed_fax" {
  name  = "/${var.env}/rails/emails_for_failed_fax"
  value = "matsushin.dev@gmail.com,matsushin.dev+test@gmail.com"
  type  = "StringList"
}

# resource "aws_ssm_parameter" "smtp_address" {
#   name  = "/${var.env}/rails/smtp_address"
#   value = "email-smtp.ap-northeast-1.amazonaws.com"
#   type  = "String"
# }

# resource "aws_ssm_parameter" "smtp_authentication" {
#   name  = "/${var.env}/rails/smtp_authentication"
#   value = "plain"
#   type  = "String"
# }

# resource "aws_ssm_parameter" "smtp_domain" {
#   name  = "${var.env}/rails/smtp_domain"
#   value = "matsushin.tech"
#   type  = "String"
# }

# resource "aws_ssm_parameter" "smtp_username" {
#   name  = "${var.env}/rails/smtp_username"
#   value = "uninitialized"
#   type  = "SecureString"

#   lifecycle {
#     ignore_changes = [value]
#   }
# }

# resource "aws_ssm_parameter" "smtp_password" {
#   name  = "${var.env}/rails/smtp_password"
#   value = "uninitialized"
#   type  = "SecureString"

#   lifecycle {
#     ignore_changes = [value]
#   }
# }

# resource "aws_ssm_parameter" "mailer_sender" {
#   name  = "${var.env}/rails/mailer_sender"
#   value = "noreply@todo.matsushin-dev.com"
#   type  = "String"
# }
