resource "aws_security_group" "sg_db" {
  name   = "${var.environment}-main-db"
  vpc_id = module.vpc.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

# allow ingress api
resource "aws_security_group_rule" "sg_db_ingress_rule_001" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 5432
  protocol                 = "all"
  security_group_id        = aws_security_group.sg_db.id
  source_security_group_id = module.api.service_sg_id
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

  identifier = "${var.environment}maindb"

  db_name        = "${var.environment}maindb"
  engine         = "postgres" # Correct engine identifier for PostgreSQL
  engine_version = "17"       # Align with major_engine_version and family parameters

  instance_class = var.main_db_instance_class

  major_engine_version = "17"
  family               = "postgres17"

  allocated_storage = 20 # Added required field

  username = "root"
  password = "root"
  port     = 5432

  vpc_security_group_ids = [
    aws_security_group.sg_db.id,
  ]

  subnet_ids = module.vpc.database_subnets

  # DB subnet group
  create_db_subnet_group = false
  db_subnet_group_name   = aws_db_subnet_group.db_sng.name

  skip_final_snapshot              = true
  final_snapshot_identifier_prefix = "final"
}