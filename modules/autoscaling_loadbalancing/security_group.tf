resource "aws_security_group" "alb" {
  name        = "${var.name_slug}-alb"
  description = "Public HTTP ingress for the ${var.repo_name} load balancer."
  vpc_id      = data.aws_vpc.default.id
}
