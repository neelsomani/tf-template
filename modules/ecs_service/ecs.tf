resource "aws_iam_role" "ecs_role" {
  name = "${var.environment}-${var.service}-ecs-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com",
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_ecs" {
  role       = aws_iam_role.ecs_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "service_role" {
  name = "${var.environment}-${var.service}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/ecs/${var.environment}-${var.service}"
  retention_in_days = 30

  tags = {
    Application = var.service
  }
}

resource "aws_ecs_task_definition" "service" {
  family             = "${var.environment}-${var.service}"
  execution_role_arn = aws_iam_role.ecs_role.arn
  task_role_arn      = aws_iam_role.service_role.arn
  container_definitions = jsonencode([
    {
      name      = var.service
      image     = "${aws_ecr_repository.ecr.repository_url}:latest"
      essential = true
      environment = [
        {
          name  = "CONFIG_FILE"
          value = var.config_file
        },
        {
          name  = "VERSION"
          value = "latest"
        }
      ]
      portMappings = [
        {
          containerPort = var.container_port,
        }
      ]
      healthCheck = {
        command     = var.healthcheck_command
        interval    = var.healthcheck_interval
        timeout     = var.healthcheck_timeout
        retries     = var.healthcheck_retries
        startPeriod = var.healthcheck_start_period
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${var.environment}-${var.service}"
          awslogs-region        = "us-west-2"
          awslogs-stream-prefix = "ecs"
        }
      }
  }])

  cpu          = var.cpu
  memory       = var.memory
  network_mode = "awsvpc"

  requires_compatibilities = ["FARGATE"]

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
}

resource "aws_ecs_service" "service" {
  name                   = "${var.environment}-${var.service}"
  cluster                = var.cluster_id
  task_definition        = aws_ecs_task_definition.service.arn
  desired_count          = var.desired_count
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets         = var.private_subnets
    security_groups = [aws_security_group.service_sg.id]
  }

  dynamic "load_balancer" {
    for_each = var.enable_lb ? [1] : []
    content {
      target_group_arn = aws_lb_target_group.service.arn
      container_name   = var.service
      container_port   = var.container_port
    }
  }

  dynamic "load_balancer" {
    for_each = var.enable_internal_lb ? [1] : []
    content {
      target_group_arn = aws_lb_target_group.service_internal[0].arn
      container_name   = var.service
      container_port   = var.container_port
    }
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  force_new_deployment = true

  lifecycle {
    ignore_changes = [task_definition]
  }
}

resource "aws_route53_record" "api" {
  count   = var.enable_lb && var.zone_id != "" ? 1 : 0
  zone_id = var.zone_id
  name    = "${var.environment}-${var.service}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_alb.alb.dns_name]
}
