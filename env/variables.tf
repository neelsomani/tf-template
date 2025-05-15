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
  default     = "db.t4g.micro"
  description = "default instance type"
}

variable "domain_certificate_arn" {
  type        = string
  description = "Certificate arn for the api server domain"
}

variable "api_config_file_name" {
  type        = string
  description = "Config file path for api service"
}

variable "global_zone_id" {
  type        = string
  description = "Zone ID from the global module for the main domain."
}