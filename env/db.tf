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

module "aurora-db" {
  source = "terraform-aws-modules/rds-aurora/aws"

  name           = "${var.environment}-main-db"
  engine         = "aurora-postgresql"
  engine_version = "13.12"

  instance_class = var.main_db_instance_class
  instances = {
    one = {}
    two = {}
  }

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.database_subnets

  vpc_security_group_ids = [
    aws_security_group.sg_db.id,
  ]

  create_db_subnet_group = false
  db_subnet_group_name   = aws_db_subnet_group.db_sng.name

  master_username = "root"
  master_password = "root"
  port            = 5432
}
