resource "aws_lb" "load_balancer" {
  name               = "${var.repo_name}-load-balancer"
  load_balancer_type = "application"
  subnets            = data.aws_subnet_ids.default.ids
  security_groups    = [aws_security_group.security_group.id]
}