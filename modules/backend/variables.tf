variable "aws_region" {
  description = "Region written into backend.hcl. The bucket is created in the provider region, which must match this value."
  type        = string
}

variable "bucket_name" {
  description = "Globally unique name of the S3 bucket that stores Terraform state."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name must be a valid S3 bucket name: 3-63 characters, lowercase letters, numbers, dots, and hyphens."
  }
}

variable "state_key" {
  description = "Object key the application stack uses inside the state bucket."
  type        = string
  default     = "react-deployer/terraform.tfstate"

  validation {
    condition     = length(var.state_key) > 0
    error_message = "state_key must be set."
  }
}
