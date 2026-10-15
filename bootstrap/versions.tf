terraform {
  required_version = "~> 1.16"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.69"
    }
  }

  # This stack creates the bucket the application stack uses, so its own state
  # stays on local disk. That file is gitignored.
  backend "local" {
    path = "terraform.tfstate"
  }
}
