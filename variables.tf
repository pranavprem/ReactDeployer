variable "aws_region" {
  description = "AWS region for the default VPC, load balancer, and instances."
  type        = string
  default     = "us-east-1"
}

variable "github_owner" {
  description = "GitHub user or organization that owns the React repository."
  type        = string
  default     = "pranavprem"

  validation {
    condition     = can(regex("^[A-Za-z0-9-]+$", var.github_owner))
    error_message = "github_owner must be a GitHub username or organization."
  }
}

variable "repo_name" {
  description = "Public GitHub repository to clone. It must npm-install and serve `npm run dev` on 0.0.0.0 and server_port."
  type        = string
  default     = "ReactCalculator"

  validation {
    condition     = can(regex("^[A-Za-z0-9_.-]+$", var.repo_name)) && length(trim(replace(lower(var.repo_name), "/[^0-9a-z-]/", "-"), "-")) > 0
    error_message = "repo_name must be a GitHub repository name containing at least one letter or number."
  }
}

variable "server_port" {
  description = "Port the dev server listens on. The repository's dev script must bind this port."
  type        = number
  default     = 8080

  validation {
    condition     = var.server_port > 0 && var.server_port < 65536
    error_message = "server_port must be between 1 and 65535."
  }
}

variable "instance_type" {
  description = "EC2 instance type for the Auto Scaling group. Must be x86_64, because the AMI filter is amd64."
  type        = string
  default     = "t3.micro"

  validation {
    condition     = length(var.instance_type) > 0
    error_message = "instance_type must be set."
  }
}

variable "node_version" {
  description = "Node.js LTS version installed on each instance before npm install."
  type        = string
  default     = "24.22.0"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.node_version))
    error_message = "node_version must look like 24.22.0."
  }
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed to SSH to the instances as the ubuntu user."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "app_cidr_blocks" {
  description = "CIDR blocks allowed to reach the dev server port. The load balancer is in another module, so this cannot be limited to its security group."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "min_size" {
  description = "Minimum number of instances in the Auto Scaling group."
  type        = number
  default     = 2

  validation {
    condition     = var.min_size >= 1
    error_message = "min_size must be at least 1."
  }
}

variable "max_size" {
  description = "Maximum number of instances in the Auto Scaling group."
  type        = number
  default     = 10

  validation {
    condition     = var.max_size >= var.min_size
    error_message = "max_size must be greater than or equal to min_size."
  }
}

variable "health_check_grace_period" {
  description = "Seconds to wait after boot before the Auto Scaling group replaces an instance that fails load balancer health checks. Covers the Node.js download and npm install."
  type        = number
  default     = 900

  validation {
    condition     = var.health_check_grace_period >= 0
    error_message = "health_check_grace_period must be zero or greater."
  }
}
