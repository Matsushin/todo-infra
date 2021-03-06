variable "vpc_id" {}
variable "name" {}

resource "aws_flow_log" "default" {
  iam_role_arn    = aws_iam_role.default.arn
  log_destination = aws_cloudwatch_log_group.default.arn
  traffic_type    = "ALL"
  vpc_id          = var.vpc_id
}

resource "aws_cloudwatch_log_group" "default" {
  name              = "${var.name}-log-group"
  retention_in_days = 90
}

resource "aws_iam_role" "default" {
  name               = "${var.name}-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "default" {
  name = "${var.name}-role-policy"
  role = aws_iam_role.default.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

