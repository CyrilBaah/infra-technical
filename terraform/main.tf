data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

module "networking" {
  source = "./modules/networking"

  project_name = var.project_name
  vpc_cidr     = "10.0.0.0/16"
  azs          = data.aws_availability_zones.available.names
}

module "security" {
  source = "./modules/security"

  project_name = var.project_name
  vpc_id       = module.networking.vpc_id
}

module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
}

module "ecs" {
  source = "./modules/ecs"

  project_name       = var.project_name
  aws_region         = var.aws_region
  vpc_id             = module.networking.vpc_id
  public_subnet_ids  = module.networking.public_subnet_ids
  alb_security_group = module.security.alb_security_group_id
  ecs_security_group = module.security.ecs_security_group_id
  ecr_repository_url = module.ecr.repository_url
}

module "github_oidc" {
  source = "./modules/github-oidc"

  project_name       = var.project_name
  github_repository  = var.github_repository
}
