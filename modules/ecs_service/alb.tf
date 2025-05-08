resource "aws_alb" "alb" {
  count = var.enable_lb ? 1 : 0

  name            = "${var.environment}-${var.service}-alb"
  internal        = false
  security_groups = [aws_security_group.sg_alb[0].id]
  subnets         = var.public_subnets
  idle_timeout    = 60
}



resource "aws_alb_listener" "service_https" {
  count = var.enable_lb ? 1 : 0

  load_balancer_arn = aws_alb.alb[0].arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.aws_acm_certificate


  default_action {
    target_group_arn = aws_lb_target_group.service.arn
    type             = "forward"
  }
}

resource "aws_alb_listener" "service_http" {
  count = var.enable_lb ? 1 : 0

  load_balancer_arn = aws_alb.alb[0].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

## Internal routes all are 403'd no matter the service
resource "aws_alb_listener_rule" "internal_routes" {
  count = var.enable_lb ? 1 : 0

  listener_arn = aws_alb_listener.service_https[0].arn
  priority     = 200

  action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "403"
    }
  }

  condition {
    path_pattern {
      values = ["/internal/*"]
    }
  }
}



