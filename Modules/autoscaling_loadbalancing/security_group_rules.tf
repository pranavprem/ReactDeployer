resource "aws_security_group_rule" "inbound_http" {
  type              = "ingress"
  security_group_id = aws_security_group.security_group.id
  from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "outbound_everything" {
  type              = "egress"
  security_group_id = aws_security_group.security_group.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}