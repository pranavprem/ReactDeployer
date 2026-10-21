variable "repo_name" {
  description = "GitHub repository name, used as a tag on instances."
  type        = string
}

variable "name_slug" {
  description = "Short lowercase prefix for AWS resource names, derived from repo_name by the root module."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]{0,22}[a-z0-9])?$", var.name_slug))
    error_message = "name_slug must be 1-24 characters of lowercase letters, numbers, and hyphens, and must not start or end with a hyphen."
  }
}

variable "server_port" {
  description = "Port the dev server listens on. Must match the launch template."
  type        = number
}

variable "launch_template_id" {
  description = "Launch template ID from the launch_template module."
  type        = string
}

variable "launch_template_version" {
  description = "Launch template version from the launch_template module."
  type        = number
}

variable "min_size" {
  description = "Minimum number of instances."
  type        = number
}

variable "max_size" {
  description = "Maximum number of instances."
  type        = number
}

variable "health_check_grace_period" {
  description = "Seconds after boot before unhealthy instances are replaced."
  type        = number
}
