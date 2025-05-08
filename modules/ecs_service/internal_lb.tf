## If internal load balancer is enabled, this resource is created
## This is primarily to enable the lambda service to hit routes not exposed to the public
## Internal routes use http
resource "aws_alb" "alb_internal" {
  count = var.enable_internal_lb ? 1 : 0

  name            = "${var.environment}-${var.service}-alb-internal"
  internal        = true
  security_groups = [aws_security_group.sg_alb[0].id]
  subnets         = var.private_subnets
  idle_timeout    = 60
}

resource "aws_lb_target_group" "service_internal" {
  count = var.enable_internal_lb ? 1 : 0

  // 32 character limit
  name        = var.use_abbrev ? "${var.environment}-${var.abbrev}-lb-tg-internal" : "${var.environment}-${var.service}-lb-tg-internal"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    enabled           = true
    healthy_threshold = 2
    interval          = 30
    path              = "/public/ping"
  }
}

resource "aws_alb_listener" "service_internal_http" {
  count = var.enable_internal_lb ? 1 : 0

  load_balancer_arn = aws_alb.alb_internal[0].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service_internal[0].arn
  }
}
