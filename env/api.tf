module "api" {
  source      = "../modules/ecs_service"
  environment = var.environment
  service     = "api"
  abbrev      = "api"

  config_file    = var.api_config_file_name
  container_port = 9001
  vpc_id         = module.vpc.vpc_id

  cluster_id      = aws_ecs_cluster.main.id
  private_subnets = module.vpc.private_subnets
  public_subnets  = module.vpc.public_subnets

  enable_internal_lb  = true
  aws_acm_certificate = var.domain_certificate_arn
  zone_id             = var.global_zone_id
}

resource "aws_iam_role_policy_attachment" "api_secrets_policy_attachment" {
  role       = module.api.ecs_role_name
  policy_arn = aws_iam_policy.secrets_policy.arn
}

resource "aws_iam_role_policy_attachment" "api_role_sm_attachment" {
  role       = module.api.service_role_name
  policy_arn = aws_iam_policy.secrets_policy.arn
}

resource "aws_iam_role_policy_attachment" "api_role_exec_attachment" {
  role       = module.api.service_role_name
  policy_arn = aws_iam_policy.exec_policy.arn
}

# Anyone in VPC can access service
resource "aws_security_group_rule" "api_sg_tg_rule" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  cidr_blocks       = ["10.0.0.0/16"]
  security_group_id = module.api.service_sg_id

  lifecycle {
    create_before_destroy = true
  }
}

# allow egress everywhere
resource "aws_security_group_rule" "api_sg_egress_rule" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  security_group_id = module.api.service_sg_id
  cidr_blocks       = ["0.0.0.0/0"]
  lifecycle {
    create_before_destroy = true
  }
}
