variable "project_name" {}
variable "env" {}
variable "subnet_ids" {}
variable "aws_account_id" {}

resource "aws_ssm_document" "session_manager_run_shell" {
  name            = "SSM-SessionManagerRunShell"
  document_type   = "Session"
  document_format = "JSON"

  content = <<EOF
  {
    "schemaVersion": "1.0",
    "description": "Document to hold regional settings for Session Manager",
    "sessionType": "Standard_Stream",
    "inputs": {
      "s3BucketName": "${aws_s3_bucket.operation.id}",
      "cloudWatchLogGroupName": "${aws_cloudwatch_log_group.operation.name}"
    }
  }
EOF
}

resource "aws_s3_bucket" "operation" {
  bucket = "${var.project_name}-${var.env}-operation"

  lifecycle_rule {
    enabled = true

    expiration {
      days = "180"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "operation" {
  bucket                  = aws_s3_bucket.operation.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudwatch_log_group" "operation" {
  name              = "${var.project_name}-${var.env}-operation"
  retention_in_days = 180
}

resource "aws_instance" "operation" {
  ami                  = "ami-0f310fced6141e627"
  instance_type        = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2_for_ssm.name
  subnet_id            = var.subnet_ids[0]
  user_data            = <<-EOF
    #!/bin/sh
    amazon-linux-extras install -y docker
    systemctl start docker
    systemctl enable docker
    yum localinstall https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm -y
    yum-config-manager --disable mysql80-community
    yum-config-manager --enable mysql57-community
    yum install mysql-community-server -y
    systemctl start mysqld.service
    systemctl enable mysqld.service
  EOF

  tags = {
    Name = "${var.project_name}-${var.env}-bastion"
  }
}

resource "aws_iam_instance_profile" "ec2_for_ssm" {
  name = "ec2-for-ssm"
  role = module.ec2_for_ssm_role.iam_role_name
}

module "ec2_for_ssm_role" {
  source     = "../../modules/iam_role"
  name       = "${var.project_name}-${var.env}-ec2-for-ssm"
  identifier = "ec2.amazonaws.com"
  policy     = data.aws_iam_policy_document.ec2_for_ssm.json
}

data "aws_iam_policy_document" "ec2_for_ssm" {
  source_json = data.aws_iam_policy.ec2_for_ssm.policy

  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "s3:PutObject",
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
      "kms:Decrypt",
    ]
  }
}

data "aws_iam_policy" "ec2_for_ssm" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

output "operation_instance_id" {
  value = aws_instance.operation.id
}
