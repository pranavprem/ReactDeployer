locals {
  # Load balancer names allow 32 characters. "<slug>-alb" needs the slug capped at 24.
  name_slug = trim(substr(replace(lower(var.repo_name), "/[^0-9a-z-]/", "-"), 0, 24), "-")
}
