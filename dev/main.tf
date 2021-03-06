provider "aws" {
  region  = "ap-northeast-1"
  version = "3.1"
}

terraform {
  backend "s3" {
    bucket  = "todo-dev-tfstate"
    key     = "terraform.tfstate"
    region  = "ap-northeast-1"
    profile = "saml"
  }
}

data "aws_caller_identity" "current" {}
