data "aws_vpc" "default" {
  default = true
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-resolute-26.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "app" {
  key_name_prefix = "${var.name_slug}-"
  public_key      = tls_private_key.ssh.public_key_openssh

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_template" "app" {
  name_prefix   = "${var.name_slug}-"
  description   = "React dev server for ${var.repo_name}."
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.app.key_name
  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    github_owner = var.github_owner
    repo_name    = var.repo_name
    server_port  = var.server_port
    node_version = var.node_version
  }))

  vpc_security_group_ids = [aws_security_group.app.id]

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  update_default_version = true

  lifecycle {
    create_before_destroy = true
  }
}
