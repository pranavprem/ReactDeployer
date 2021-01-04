output "private_key" {
  value       = tls_private_key.public_key.private_key_pem
  description = "the public key that will be used for ssh"
  sensitive   = true
}

output "launch_config_name" {
  value       = aws_launch_configuration.launch_config.name
  description = "Name of the launch configuration to be used as input for other modules"
}

output "server_port" {
  value       = var.server_port
  description = "Port for server to be used as input for other modules"
}

output "repo_name" {
  value = var.repo_name
  description = "Name of repository to be used as input for other modules"
}