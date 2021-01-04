data "template_file" "user_data" {
  template = file("${path.module}/user-data.sh")
  vars = {
    repo_name = var.repo_name
  }
}