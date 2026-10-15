variable "repo_name" {
  description = "Public GitHub repository cloned onto each instance."
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

variable "github_owner" {
  description = "GitHub user or organization that owns repo_name."
  type        = string
}

variable "server_port" {
  description = "Port exported as PORT for the dev server."
  type        = number
}

variable "instance_type" {
  description = "EC2 instance type. The AMI is x86_64."
  type        = string
}

variable "node_version" {
  description = "Node.js version downloaded from nodejs.org."
  type        = string
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed to open SSH."
  type        = list(string)
}

variable "app_cidr_blocks" {
  description = "CIDR blocks allowed to open the dev server port."
  type        = list(string)
}
