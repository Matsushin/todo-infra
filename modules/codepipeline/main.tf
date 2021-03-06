variable "aws_account_id" {}
variable "backend_codepipeline_name" {}
variable "front_codepipeline_name" {}
variable "env" {}
variable "github_organization" {}
variable "backend_github_repository_name" {}
variable "front_github_repository_name" {}
variable "backend_github_branch" {}
variable "front_github_branch" {}
variable "project_name" {}
# variable "front_bucket_name" {}
# variable "distribution_id" {}
# variable "api_base_url" {}

variable "artifact_bucket_name" {}
variable "artifact_bucket_force_destroy" {
  default = false
}
variable "github_token" {}
variable "ecs_cluster_name" {}
variable "ecs_service_backend_name" {}
variable "ecs_service_front_name" {}
variable "action_on_timeout" {
  default = "CONTINUE_DEPLOYMENT"
}
variable "wait_time_in_minutes" {
  default = 0
}
variable "termination_wait_time_in_minutes" {
  default = 2880
}
variable "codepipeline_role_name" {
  default = "codepipeline"
}

provider "github" {
  organization = var.github_organization
  token        = var.github_token
}

resource "github_repository_webhook" "backend" {
  repository = var.backend_github_repository_name

  configuration {
    url          = aws_codepipeline_webhook.backend.url
    secret       = "VeryRandomStringMoreThan20Byte!"
    content_type = "json"
    insecure_ssl = false
  }

  events = ["push"]
}

resource "github_repository_webhook" "front" {
  repository = var.front_github_repository_name

  configuration {
    url          = aws_codepipeline_webhook.front.url
    secret       = "VeryRandomStringMoreThan20Byte!"
    content_type = "json"
    insecure_ssl = false
  }

  events = ["push"]
}

resource "aws_codepipeline_webhook" "backend" {
  name            = var.backend_codepipeline_name
  target_pipeline = aws_codepipeline.backend.name
  target_action   = "Source"
  authentication  = "GITHUB_HMAC"

  authentication_configuration {
    secret_token = "VeryRandomStringMoreThan20Byte!"
  }

  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/{Branch}"
  }

  lifecycle {
    ignore_changes = [
      authentication_configuration
    ]
  }
}

resource "aws_codepipeline_webhook" "front" {
  name            = var.front_codepipeline_name
  target_pipeline = aws_codepipeline.front.name
  target_action   = "Source"
  authentication  = "GITHUB_HMAC"

  authentication_configuration {
    secret_token = "VeryRandomStringMoreThan20Byte!"
  }

  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/{Branch}"
  }

  lifecycle {
    ignore_changes = [
      authentication_configuration
    ]
  }
}

resource "aws_codepipeline" "backend" {
  name     = var.backend_codepipeline_name
  role_arn = module.codepipeline_role.iam_role_arn

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = 1
      output_artifacts = ["Source"]
      configuration = {
        OAuthToken           = var.github_token
        Owner                = var.github_organization
        Repo                 = var.backend_github_repository_name
        Branch               = var.backend_github_branch
        PollForSourceChanges = false
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = 1
      input_artifacts  = ["Source"]
      output_artifacts = ["Build"]
      configuration = {
        ProjectName = aws_codebuild_project.backend.id
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy-backend"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = 1
      input_artifacts = ["Build"]
      configuration = {
        ClusterName = var.ecs_cluster_name
        ServiceName = var.ecs_service_backend_name
        FileName    = "imagedefinitions.json"
      }
    }
  }

  artifact_store {
    location = aws_s3_bucket.artifact.id
    type     = "S3"
  }

  lifecycle {
    ignore_changes = [stage[0].action[0].configuration]
  }
}

resource "aws_codepipeline" "front" {
  name     = var.front_codepipeline_name
  role_arn = module.codepipeline_role.iam_role_arn

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = 1
      output_artifacts = ["Source"]
      configuration = {
        OAuthToken           = var.github_token
        Owner                = var.github_organization
        Repo                 = var.front_github_repository_name
        Branch               = var.front_github_branch
        PollForSourceChanges = false
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = 1
      input_artifacts  = ["Source"]
      output_artifacts = ["Build"]
      configuration = {
        ProjectName = aws_codebuild_project.front.id
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy-front"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = 1
      input_artifacts = ["Build"]
      configuration = {
        ClusterName = var.ecs_cluster_name
        ServiceName = var.ecs_service_front_name
        FileName    = "imagedefinitions.json"
      }
    }
  }

  artifact_store {
    location = aws_s3_bucket.artifact.id
    type     = "S3"
  }

  lifecycle {
    ignore_changes = [stage[0].action[0].configuration]
  }
}

resource "aws_s3_bucket" "artifact" {
  bucket        = var.artifact_bucket_name
  force_destroy = var.artifact_bucket_force_destroy

  lifecycle_rule {
    enabled = true
    expiration {
      days = "180"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "artifact" {
  bucket                  = aws_s3_bucket.artifact.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

module "codepipeline_role" {
  source     = "../../modules/iam_role"
  name       = var.codepipeline_role_name
  identifier = "codepipeline.amazonaws.com"
  policy     = data.aws_iam_policy_document.codepipeline.json
}

data "aws_iam_policy_document" "codepipeline" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:DescribeTasks",
      "ecs:ListTasks",
      "ecs:RegisterTaskDefinition",
      "ecs:UpdateService",
      "secretsmanager:GetSecretValue",
      "iam:PassRole",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "codepipeline_AWSCodeDeployRoleForECS" {
  role       = "codepipeline"
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

resource "aws_iam_role_policy_attachment" "codepipeline_AWSCodeDeployFullAccess" {
  role       = "codepipeline"
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess"
}
