resource "aws_autoscaling_group" "app" {
  name_prefix         = "${var.name_slug}-"
  vpc_zone_identifier = local.subnet_ids
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.min_size

  # EC2 checks stay green even when npm never starts. ELB checks replace that
  # failure, after a grace period long enough for the Node download and npm install.
  # Apply itself does not wait; test.sh polls the load balancer.
  health_check_type         = "ELB"
  health_check_grace_period = var.health_check_grace_period
  wait_for_capacity_timeout = "0"

  launch_template {
    id      = var.launch_template_id
    version = tostring(var.launch_template_version)
  }

  target_group_arns = [aws_lb_target_group.app.arn]

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      instance_warmup        = var.health_check_grace_period
    }
  }

  dynamic "tag" {
    for_each = {
      Name = "${var.name_slug}-app"
      Repo = var.repo_name
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
