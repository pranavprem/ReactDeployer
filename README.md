# ReactDeployer

## About

After completing 4 chapters of "Terraform: Up and Running" by Yevgeniy Brikman, I've made a piece of Terraform that can deploy any pure React repository in my GitHub as a way to test out all the concepts I've learned so far.

It consists of the usage of 3 modules:

### Backend

This module sets up the backend for Terraform state storage.

This module will be executed first if you want a remote state storage.

Uses s3 for storage and dynamoDB for locking.

### Launch_config

This sets up the launch config of the EC2s which can install dependencies, clone a repo and run it.

### autoscaling_loadbalancing

This sets up an autoscaling group of servers based on the above launch config and a load balancer to go along with it.

## Pre-requisistes

The react code must be configured to run in dev mode i.e. npm must have a "dev" target that does:

[`"dev": "webpack-dev-server --content-base src --inline --hot --host 0.0.0.0"`](https://github.com/pranavprem/ReactCalculator/blob/1230daac9d421d481743526c98c2b18f8497e591/package.json#L23)

## Future Work

- Add a module for back-end as needed with different react projects.
- Add some terratest and something that initializes the state store automatically.

## Setup

1. Run the create_backend.tf with everything else blank (terraform init; terraform apply)
2. Add the state store back end details to main.tf and run terraform init.
3. Add the other files and run them (terraform apply)
