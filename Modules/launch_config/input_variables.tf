variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

variable "repo_name" {
  description = "The name of the GitHub Repo needed"
  type        = string
  default     = "ReactCalculator"
}