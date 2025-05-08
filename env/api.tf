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
}