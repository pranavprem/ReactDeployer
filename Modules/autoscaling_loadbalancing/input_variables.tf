variable "repo_name" {
  description = "The name of the GitHub Repo containing React Code"
  type        = string
  default     = "ReactCalculator"
}

variable "launch_config_name" {
  description = "The name of the Launch Config obtained from the launch config module"
  type        = string
  default     = "NoDefaultAvailable"
}

variable "server_port" {
  description = "The port that the application server listens on, obtained from launch config module"
  type = string
  default = 8080
}