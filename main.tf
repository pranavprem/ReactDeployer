provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "react-deployer"
      ManagedBy = "terraform"
      Repo      = var.repo_name
    }
  }
}
