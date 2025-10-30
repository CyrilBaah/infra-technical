data "aws_caller_identity" "current" {}

# Try to get existing OIDC provider
data "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 0 : 1
  url   = "https://token.actions.githubusercontent.com"
}

# Create OIDC provider if it doesn't exist
resource "aws_iam_openid_connect_provider" "github" {
  count           = var.create_oidc_provider ? 1 : 0
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# Try to get existing IAM role
data "aws_iam_role" "github_actions" {
  count = var.create_github_role ? 0 : 1
  name  = "${var.project_name}-github-actions"
}

# Create IAM role if it doesn't exist
resource "aws_iam_role" "github_actions" {
  count = var.create_github_role ? 1 : 0
  name  = "${var.project_name}-github-actions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = local.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repository}:*"
          }
        }
      }
    ]
  })
}

locals {
  oidc_provider_arn = var.create_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : data.aws_iam_openid_connect_provider.github[0].arn
  github_role_arn   = var.create_github_role ? aws_iam_role.github_actions[0].arn : data.aws_iam_role.github_actions[0].arn
  github_role_name  = var.create_github_role ? aws_iam_role.github_actions[0].name : data.aws_iam_role.github_actions[0].name
}

resource "aws_iam_role_policy" "github_actions" {
  name = "${var.project_name}-github-actions-policy"
  role = local.github_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*",
          "ecr:*",
          "ecs:*",
          "ec2:*",
          "elasticloadbalancing:*",
          "logs:*",
          "iam:*",
          "application-autoscaling:*"
        ]
        Resource = "*"
      }
    ]
  })
}
