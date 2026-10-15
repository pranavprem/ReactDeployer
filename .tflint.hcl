# TFLint 0.64 with the AWS ruleset pinned to match the AWS provider 6.69 line.
# Install plugins with `tflint --init` from the repository root.

tflint {
  required_version = ">= 0.64.0"
}

config {
  call_module_type = "local"
  force            = false
}

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "aws" {
  enabled = true
  version = "0.49.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}
