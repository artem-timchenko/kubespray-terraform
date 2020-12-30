provider "aws" {
  region                  = var.aws_region
  shared_credentials_file = var.shared_credentials_file
  profile                 = var.shared_credentials_profile
  version                 = "~> 2.46"
}
