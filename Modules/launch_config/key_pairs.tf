resource "aws_key_pair" "key_pair" {
  key_name   = "${var.repo_name}_key_pair"
  public_key = tls_private_key.public_key.public_key_openssh
}


resource "tls_private_key" "public_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}