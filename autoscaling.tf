module "autoscaling_loadbalancing" {
  source = "./modules/autoscaling_loadbalancing"

  repo_name                 = var.repo_name
  name_slug                 = local.name_slug
  server_port               = var.server_port
  launch_template_id        = module.launch_template.launch_template_id
  launch_template_version   = module.launch_template.launch_template_version
  min_size                  = var.min_size
  max_size                  = var.max_size
  health_check_grace_period = var.health_check_grace_period
}
