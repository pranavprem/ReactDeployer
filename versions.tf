terraform {
  required_version = "~> 1.16"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.69"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.4"
    }
  }

  # Partial configuration. Copy backend.hcl.example to backend.hcl after bootstrap
  # and run: terraform init -backend-config=backend.hcl
  # Checks that must not touch AWS use: terraform init -backend=false
  backend "s3" {}
}
