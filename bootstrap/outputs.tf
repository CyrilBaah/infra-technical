output "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = module.bootstrap.s3_bucket_name
}

output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions IAM role"
  value       = local.github_role_arn
}

output "oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider"
  value       = local.oidc_provider_arn
}
