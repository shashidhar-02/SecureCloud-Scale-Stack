resource "random_password" "rds_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "rds_password" {
  name                    = "${var.environment}-rds-password-secret"
  description             = "Master password for RDS instance"
  kms_key_id              = var.kms_key_arn
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "rds_password" {
  secret_id     = aws_secretsmanager_secret.rds_password.id
  secret_string = random_password.rds_password.result
}

resource "aws_db_instance" "main" {
  identifier = "${var.environment}-db"

  engine            = "postgres"
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type      = "gp3"

  db_name  = "securecloud"
  username = var.db_username
  password = random_password.rds_password.result

  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [var.rds_security_group_id]

  # DevSecOps & Best Practices
  storage_encrypted   = true
  kms_key_id          = var.kms_key_arn
  multi_az            = var.multi_az
  publicly_accessible = false

  deletion_protection = var.deletion_protection
  skip_final_snapshot = !var.deletion_protection

  backup_retention_period = var.backup_retention_period
  backup_window           = "03:00-04:00"

  performance_insights_enabled          = true
  performance_insights_kms_key_id       = var.kms_key_arn
  performance_insights_retention_period = 7

  auto_minor_version_upgrade = true

  tags = merge(var.tags, { Name = "${var.environment}-rds" })

  lifecycle {
    ignore_changes = [password]
  }
}
