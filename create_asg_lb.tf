module "create_asg_lb" {
    source = "./Modules/autoscaling_loadbalancing"
    launch_config_name = module.create_launch_config.launch_config_name
    server_port = module.create_launch_config.server_port
}