variable "environment" {
  type        = string
  default     = "prod"
  description = "Name of the environment"
}

variable "project_name" {
  type        = string
  default     = "project_name"
  description = "Name of the project"
}

variable "region" {
  type        = string
  default     = "us-west-2"
  description = "Region"
}

variable "main_db_instance_class" {
  type        = string
  default     = "db.t2.small"
  description = "default instance type"
}
