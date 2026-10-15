locals {
  subnet_ids = sort(tolist(data.aws_subnets.default.ids))
}
