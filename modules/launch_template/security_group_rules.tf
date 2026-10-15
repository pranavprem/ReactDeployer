resource "aws_security_group_rule" "app_ingress" {
  description       = "Dev server. Open to app_cidr_blocks because the load balancer security group is created later."
  type              = "ingress"
  security_group_id = aws_security_group.app.id
  from_port         = var.server_port
  to_port           = var.server_port
  protocol          = "tcp"
  cidr_blocks       = var.app_cidr_blocks
}

resource "aws_security_group_rule" "ssh_ingress" {
  description       = "SSH as the ubuntu user, using the key Terraform stores in state."
  type              = "ingress"
  security_group_id = aws_security_group.app.id
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.ssh_cidr_blocks
}

resource "aws_security_group_rule" "app_egress" {
  description       = "Outbound access for apt, git, and npm."
  type              = "egress"
  security_group_id = aws_security_group.app.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
