output "alb_dns_name" {
  description = "DNS name of the application load balancer."
  value       = module.autoscaling_loadbalancing.alb_dns_name
}

output "alb_url" {
  description = "HTTP URL served by the load balancer. This is what test.sh requests."
  value       = "http://${module.autoscaling_loadbalancing.alb_dns_name}/"
}

output "private_key_pem" {
  description = "SSH private key for the ubuntu user on the instances. Terraform stores it in state; keep the state bucket private."
  value       = module.launch_template.private_key_pem
  sensitive   = true
}
