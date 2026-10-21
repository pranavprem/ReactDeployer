resource "aws_lb" "app" {
  name                       = "${var.name_slug}-alb"
  load_balancer_type         = "application"
  subnets                    = local.subnet_ids
  security_groups            = [aws_security_group.alb.id]
  drop_invalid_header_fields = true
}
