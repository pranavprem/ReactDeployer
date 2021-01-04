variable "bucket_name" {
  description = "Name of S3 bucket that will store state"
  default     = "terraform-remote-state-pranav"
  type        = string
}

variable "dynamo_db_name" {
  description = "Name of Dynamo DB that will store state modification locks"
  default     = "terraform-locks-pranav"
  type        = string
}