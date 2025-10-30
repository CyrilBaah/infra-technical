terraform {
  backend "s3" {
    bucket  = "hello-api-terraform-state"
    key     = "terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
}
