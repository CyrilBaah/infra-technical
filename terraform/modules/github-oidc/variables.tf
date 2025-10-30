variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "github_repository" {
  description = "GitHub repository in format owner/repo"
  type        = string
}

variable "create_oidc_provider" {
  description = "Whether to create OIDC provider (true) or use existing (false)"
  type        = bool
  default     = true
}

variable "create_github_role" {
  description = "Whether to create GitHub role (true) or use existing (false)"
  type        = bool
  default     = true
}
