output "ecs_role_name" {
  value = aws_iam_role.ecs_role.name
}

output "service_role_name" {
  value = aws_iam_role.service_role.name
}

output "service_sg_id" {
  value = aws_security_group.service_sg.id
}