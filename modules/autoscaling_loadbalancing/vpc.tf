data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

check "default_subnets" {
  assert {
    condition     = length(data.aws_subnets.default.ids) >= 2
    error_message = "The default VPC in this region needs at least two subnets so the load balancer can span Availability Zones."
  }
}
