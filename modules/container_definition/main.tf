variable "env" {}
variable "name" {}
variable "container_name" {}
variable "aws_account_id" {}
variable "project_name" {}

data "template_file" "default" {
  template = file("${path.module}/../../container_definitions/${var.name}.json")
  vars = {
    env            = var.env
    aws_account_id = var.aws_account_id
    project_name   = var.project_name
    container_name = var.container_name
  }
}

output "rendered" {
  value = data.template_file.default.rendered
}
