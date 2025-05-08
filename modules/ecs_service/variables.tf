variable "environment" {
  type        = string
  default     = "prod-001"
  description = "Name of the environment"
}

variable "service" {
  type        = string
  description = "Name of the service"
}

variable "cpu" {
  type        = number
  default     = 512
  description = "CPU for the task"
}

variable "memory" {
  type        = number
  default     = 1024
  description = "Memory for the task"
}

variable "config_file" {
  type        = string
  description = "Path to the config file"
}

variable "container_port" {
  type        = number
  description = "Port the container listens on"
}

variable "healthcheck_command" {
  type        = list(string)
  description = "Command to run for healthcheck"
  default     = ["CMD-SHELL", "curl -f http://localhost:9001/public/ping||exit 1"]
}

variable "healthcheck_interval" {
  type        = number
  description = "Interval for healthcheck"
  default     = 30
}

variable "healthcheck_timeout" {
  type        = number
  description = "Timeout for healthcheck"
  default     = 5
}

variable "healthcheck_retries" {
  type        = number
  description = "Retries for healthcheck"
  default     = 3
}

variable "healthcheck_start_period" {
  type        = number
  description = "Start period for healthcheck"
  default     = 10
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "cluster_id" {
  type        = string
  description = "Cluster ID"
}

variable "private_subnets" {
  type        = list(string)
  description = "Private subnets"
}

variable "public_subnets" {
  type        = list(string)
  description = "Public subnets"
}

variable "enable_internal_lb" {
  type        = bool
  description = "Enable internal load balancer"
  default     = false
}

variable "enable_lb" {
  type        = bool
  description = "Enable load balancer"
  default     = true
}

variable "abbrev" {
  type        = string
  description = "Abbreviation for the service"
}

variable "use_abbrev" {
  type        = bool
  description = "Use abbreviation for the service"
  default     = false
}

variable "desired_count" {
  type        = number
  description = "Desired count for the service"
  default     = 1
}

variable "aws_acm_certificate" {
  type        = string
  description = "ACM Certificate"
}