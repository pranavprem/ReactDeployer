resource "aws_autoscaling_group" "auto_scaling_group" {
  launch_configuration = var.launch_config_name
  vpc_zone_identifier  = data.aws_subnet_ids.default.ids

  min_size = 2
  max_size = 10

  target_group_arns = [aws_lb_target_group.target_group.arn]

  tag {
    key                 = "Name"
    value               = "${var.repo_name}_auto_scaling_group"
    propagate_at_launch = true
  }
}