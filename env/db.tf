resource "aws_security_group" "sg_db" {
  name   = "${var.environment}-main-db"
  vpc_id = module.vpc.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_subnet_group" "db_sng" {
  name       = "${var.environment}-main-db-sng"
  subnet_ids = module.vpc.database_subnets

  tags = {
    Name = "${var.environment}-main-db-sng"
  }
}

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${var.environment}-main-db"

  db_name        = "${var.environment}-main-db"
  engine         = "postgresql"
  engine_version = "17.2-R2"

  username = "root"
  password = "root"
  port     = 5432

  vpc_security_group_ids = [
    aws_security_group.sg_db.id,
  ]

  subnets = module.vpc.database_subnets

  # DB subnet group
  create_db_subnet_group = false
  db_subnet_group_name   = aws_db_subnet_group.db_sng.name
}