variable "aws_region" {
  description = "AWS region for the state bucket. Use the same region in backend.hcl."
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name for Terraform state. There is no default, because bucket names belong to one account."
  type        = string
}

variable "state_key" {
  description = "Object key the application stack uses inside the state bucket."
  type        = string
  default     = "react-deployer/terraform.tfstate"
}
