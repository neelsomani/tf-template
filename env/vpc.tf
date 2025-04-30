module "vpc" {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc"

  name = "${var.environment}-${var.project_name}"
  cidr = "10.0.0.0/16"

  azs                 = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets      = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  database_subnets    = ["10.0.21.0/24", "10.0.22.0/24"]

  enable_ipv6 = false

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  tags = {
    Owner = "terraform"
  }

  vpc_tags = {
    Name = var.project_name
  }
}
