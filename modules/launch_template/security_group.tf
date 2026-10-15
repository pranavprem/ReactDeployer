resource "aws_security_group" "app" {
  name        = "${var.name_slug}-app"
  description = "React dev server and SSH for ${var.repo_name}."
  vpc_id      = data.aws_vpc.default.id
}
