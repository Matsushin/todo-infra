locals {
  front_environment_variables = [
    {
      name  = "NUXT_HOST"
      value = "/${var.env}/nuxt/host"
    },
    {
      name  = "NUXT_PORT"
      value = "/${var.env}/nuxt/port"
    },
    {
      name  = "NUXT_ENV_API_BASE_URL"
      value = "/${var.env}/nuxt/api_base_url"
    },
    {
      name  = "NUXT_ENV_BASIC_NAME"
      value = "/${var.env}/nuxt/basic_auth_name"
    },
    {
      name  = "NUXT_ENV_BASIC_PASS"
      value = "/${var.env}/nuxt/basic_auth_password"
    },
    {
      name  = "NUXT_ENV_ENABLE_BASIC_AUTH"
      value = "/${var.env}/nuxt/basic_auth_enabled"
    },
    {
      name  = "DOCKERHUB_USER"
      value = "/${var.env}/build/dockerhub_username"
    },
    {
      name  = "DOCKERHUB_PASS"
      value = "/${var.env}/build/dockerhub_password"
    }
  ]

  backend_environment_variables = [
    {
      name  = "API_SERVER_DATABASE_HOST"
      value = "/${var.env}/db/host"
    },
    {
      name  = "API_SERVER_DATABASE_NAME"
      value = "/${var.env}/db/username"
    },
    {
      name  = "API_SERVER_DATABASE_USER"
      value = "/${var.env}/db/password"
    },
    {
      name  = "SECRET_KEY_BASE"
      value = "/${var.env}/rails/secret_key"
    },
    {
      name  = "S3_RESOURCE_BUCKET"
      value = "/${var.env}/s3/resource_bucket"
    },
    {
      name  = "ADMIN_BASIC_AUTH_NAME"
      value = "/${var.env}/rails/basic_auth_name"
    },
    {
      name  = "ADMIN_BASIC_AUTH_PASSWORD"
      value = "/${var.env}/rails/basic_auth_password"
    },
    {
      name  = "DOCKERHUB_USER"
      value = "/${var.env}/build/dockerhub_username"
    },
    {
      name  = "DOCKERHUB_PASS"
      value = "/${var.env}/build/dockerhub_password"
    }
  ]
}

resource "aws_codebuild_project" "front" {
  name         = "${var.front_github_repository_name}-${var.env}-codebuild"
  service_role = module.codebuild_role.iam_role_arn

  source {
    type = "CODEPIPELINE"
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_CUSTOM_CACHE"]
  }

  environment {
    type            = "LINUX_CONTAINER"
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:4.0"
    privileged_mode = true

    environment_variable {
      name  = "ENV"
      value = var.env
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.aws_account_id
    }
    dynamic "environment_variable" {
      for_each = local.front_environment_variables
      content {
        name  = environment_variable.value["name"]
        value = environment_variable.value["value"]
        type  = "PARAMETER_STORE"
      }
    }
  }
}

# resource "aws_codebuild_project" "front" {
#   name         = "${var.backend_front_repository_name}-${var.env}-codebuild"
#   service_role = module.codebuild_role.iam_role_arn
#
#   source {
#     type = "CODEPIPELINE"
#   }
#
#   artifacts {
#     type = "CODEPIPELINE"
#   }
#
#   cache {
#     type  = "LOCAL"
#     modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_CUSTOM_CACHE"]
#   }
#
#   environment {
#     type            = "LINUX_CONTAINER"
#     compute_type    = "BUILD_GENERAL1_SMALL"
#     image           = "aws/codebuild/standard:4.0"
#     privileged_mode = true
#
#     environment_variable {
#       name  = "ENV"
#       value = var.env
#     }
#   }
# }

resource "aws_codebuild_project" "backend" {
  name         = "${var.backend_github_repository_name}-${var.env}-codebuild"
  service_role = module.codebuild_role.iam_role_arn

  source {
    type = "CODEPIPELINE"
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_CUSTOM_CACHE"]
  }

  environment {
    type            = "LINUX_CONTAINER"
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:4.0"
    privileged_mode = true

    environment_variable {
      name  = "ENV"
      value = var.env
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.aws_account_id
    }
    dynamic "environment_variable" {
      for_each = local.backend_environment_variables
      content {
        name  = environment_variable.value["name"]
        value = environment_variable.value["value"]
        type  = "PARAMETER_STORE"
      }
    }
  }
}

module "codebuild_role" {
  source     = "../../modules/iam_role"
  name       = "${var.project_name}-${var.env}-codebuild"
  identifier = "codebuild.amazonaws.com"
  policy     = data.aws_iam_policy_document.codebuild.json
}

data "aws_iam_policy_document" "codebuild" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:ListBucket",
      "cloudfront:CreateInvalidation",
      "cloudfront:GetDistribution",
      "cloudfront:GetInvalidation",
      "cloudfront:GetStreamingDistribution",
      "cloudfront:GetDistributionConfig",
      "cloudfront:ListDistributions",
      "cloudfront:ListInvalidations",
      "cloudfront:ListStreamingDistributions",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ec2:GetReousitoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ecr:GetDownloadUrlForLayer",
      "secretsmanager:GetSecretValue",
      # TODO 権限を絞る
      "ssm:GetParameters",
      "kms:Decrypt"
    ]
  }
}

