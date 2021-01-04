resource "aws_security_group" "security_group" {
  name = "${var.repo_name}_lb_security_group"
}