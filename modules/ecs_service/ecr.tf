resource "aws_ecr_repository" "ecr" {
  name                 = "${var.environment}-${var.service}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}