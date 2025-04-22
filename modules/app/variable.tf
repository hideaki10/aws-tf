variable "ecr_repository_name" {
  type        = string
  description = "The name of the ECR repository"
}

variable "app_path" {
  type        = string
  description = "The path to the app"
}

variable "image_version" {
  type        = string
  description = "The version of the image"
}

variable "app_name" {
  type        = string
  description = "The name of the app"
}

variable "port" {
  type        = number
  description = "The port of the app"
}

variable "ecs_execution_role_arn" {
  type        = string
  description = "The ARN of the ECS execution role"
}

variable "subnets" {
  type        = list(string)
  description = "The subnets to deploy the app to"
}

variable "security_group" {
  type        = string
  description = "The security group to deploy the app to"
}

variable "is_public" {
  type        = bool
  description = "Whether the app is public"
  default     = true
}

variable "cluster_arn" {
  type        = string
  description = "The ARN of the ECS cluster"
}
