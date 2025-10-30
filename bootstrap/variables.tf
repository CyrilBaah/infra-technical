variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "hello-api"
}

variable "github_repository" {
  description = "GitHub repository in format owner/repo"
  type        = string
  default     = "*/*"
}

variable "create_oidc_provider" {
  description = "Whether to create OIDC provider (true) or use existing (false)"
  type        = bool
  default     = false
}

variable "create_github_role" {
  description = "Whether to create GitHub role (true) or use existing (false)"
  type        = bool
  default     = false
}
