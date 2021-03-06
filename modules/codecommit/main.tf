variable "repository_name" {}
variable "description" {}
variable "frontend_repository_name" {}
variable "frontend_description" {}
variable "codecommit_policy_name" {}
variable "codecommit_user_name" {}

resource "aws_codecommit_repository" "default" {
  repository_name = var.repository_name
  description     = var.description
}

resource "aws_codecommit_repository" "frontend" {
  repository_name = var.frontend_repository_name
  description     = var.frontend_description
}

resource "aws_iam_user" "codecommit" {
  name = var.codecommit_user_name
}

data "aws_iam_policy_document" "codecommit" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "codecommit:GitPull",
      "codecommit:GitPush"
    ]
  }
}

resource "aws_iam_policy" "codecommit" {
  name   = var.codecommit_policy_name
  policy = data.aws_iam_policy_document.codecommit.json
}

resource "aws_iam_user_policy_attachment" "codecommit" {
  user       = aws_iam_user.codecommit.name
  policy_arn = aws_iam_policy.codecommit.arn
}

