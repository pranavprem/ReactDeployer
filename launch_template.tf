module "launch_template" {
  source = "./modules/launch_template"

  repo_name       = var.repo_name
  name_slug       = local.name_slug
  github_owner    = var.github_owner
  server_port     = var.server_port
  instance_type   = var.instance_type
  node_version    = var.node_version
  ssh_cidr_blocks = var.ssh_cidr_blocks
  app_cidr_blocks = var.app_cidr_blocks
}
