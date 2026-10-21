output "launch_template_id" {
  description = "ID of the launch template used by the Auto Scaling group."
  value       = aws_launch_template.app.id
}

output "launch_template_version" {
  description = "Latest launch template version. Pinning this, rather than $Latest, makes template edits roll the group."
  value       = aws_launch_template.app.latest_version
}

output "private_key_pem" {
  description = "PEM private key for SSH. Stored in Terraform state."
  value       = tls_private_key.ssh.private_key_pem
  sensitive   = true
}
