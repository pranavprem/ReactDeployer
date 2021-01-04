output "alb_dns_name" {
    description = "The DNS name needed to run test.sh"
    value = module.create_asg_lb.alb_dns_name
}