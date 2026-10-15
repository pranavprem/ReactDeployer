output "bucket_name" {
  description = "Name of the S3 bucket that stores application state."
  value       = aws_s3_bucket.terraform_state.id
}

output "backend_hcl" {
  description = "backend.hcl body for the application stack. Redirect it to ../backend.hcl before terraform init there."
  value = join("\n", [
    "bucket       = \"${aws_s3_bucket.terraform_state.id}\"",
    "key          = \"${var.state_key}\"",
    "region       = \"${var.aws_region}\"",
    "encrypt      = true",
    "use_lockfile = true",
    "",
  ])
}
