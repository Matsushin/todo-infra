variable "name" {}
variable "db_name" {}
variable "username" {}
variable "instance_class" {}
variable "subnets" {}
variable "vpc_security_group_ids" {}
variable "backup_retention_period" {
  default = 7
}

resource "aws_db_subnet_group" "default" {
  name       = var.name
  subnet_ids = var.subnets
}

resource "aws_db_parameter_group" "default" {
  name   = var.name
  family = "aurora-mysql5.7"
}

resource "aws_rds_cluster_parameter_group" "default" {
  name   = var.name
  family = "aurora-mysql5.7"

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_connection"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_results"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_filesystem"
    value = "binary"
  }
  # parameter {
  #   name  = "collation_connection"
  #   value = "utf8mb4_general_ci"
  # }
  # parameter {
  #   name         = "skip-character-set-client-handshake"
  #   value        = "1"
  #   apply_method = "pending-reboot"
  # }
  parameter {
    name  = "slow_query_log"
    value = "1"
  }
  parameter {
    name  = "long_query_time"
    value = "1"
  }
  parameter {
    name  = "general_log"
    value = "1"
  }
  parameter {
    name = "innodb_optimize_fulltext_only"
    value = "1"
  }
}

resource "aws_rds_cluster" "default" {
  cluster_identifier              = var.name
  engine                          = "aurora-mysql"
  database_name                   = var.db_name
  vpc_security_group_ids          = var.vpc_security_group_ids
  db_subnet_group_name            = aws_db_subnet_group.default.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.default.name
  engine_version                  = "5.7.mysql_aurora.2.07.2"
  storage_encrypted               = true
  deletion_protection             = false # 削除保護するかどうか
  master_username                 = var.username
  master_password                 = "VeryStrongPassword!"
  backup_retention_period         = var.backup_retention_period
  preferred_backup_window         = "07:00-09:00"
  skip_final_snapshot             = true
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
  apply_immediately               = true

  lifecycle {
    ignore_changes = [master_password, availability_zones]
  }
}

resource "aws_rds_cluster_instance" "default" {
  cluster_identifier      = aws_rds_cluster.default.id
  engine                  = "aurora-mysql"
  instance_class          = var.instance_class
  db_subnet_group_name    = aws_db_subnet_group.default.name
  db_parameter_group_name = aws_db_parameter_group.default.name
  apply_immediately       = true
}

output "database_endpoint" {
  value = join("", aws_rds_cluster.default.*.endpoint)
}
