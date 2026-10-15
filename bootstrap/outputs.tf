output "bucket_name" {
  description = "Name of the S3 bucket that stores application state."
  value       = module.backend.bucket_name
}

output "backend_hcl" {
  description = "backend.hcl body for the application stack. From this directory: terraform output -raw backend_hcl > ../backend.hcl"
  value       = module.backend.backend_hcl
}
