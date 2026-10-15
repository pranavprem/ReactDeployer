provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "react-deployer"
      ManagedBy = "terraform"
      Component = "terraform-state"
    }
  }
}

module "backend" {
  source = "../modules/backend"

  aws_region  = var.aws_region
  bucket_name = var.bucket_name
  state_key   = var.state_key
}
