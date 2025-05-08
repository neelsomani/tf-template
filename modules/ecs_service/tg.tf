resource "aws_lb_target_group" "service" {
  name        = "${var.environment}-${var.service}-lb-tg"
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