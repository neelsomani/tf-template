## ALB SECURITY GROUPS ##
resource "aws_security_group" "sg_alb" {
  count = var.enable_lb ? 1 : 0

  name   = "${var.environment}-${var.service}-alb-sg"
  vpc_id = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "sg_alb_rule_001" {
  count = var.enable_lb ? 1 : 0

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  security_group_id = aws_security_group.sg_alb[0].id
  cidr_blocks       = ["0.0.0.0/0"]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "sg_alb_rule_002" {
  count = var.enable_lb ? 1 : 0

  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.sg_alb[0].id
  cidr_blocks       = ["0.0.0.0/0"]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "sg_alb_rule_003" {
  count = var.enable_lb ? 1 : 0

  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.sg_alb[0].id
  cidr_blocks       = ["0.0.0.0/0"]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "service_sg" {
  name   = "${var.environment}-${var.service}-sg"
  vpc_id = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}
