provider "aws" {

}

terraform {
    backend "s3" {
        bucket = "terraform-remote-state-pranav"
        key = "global/s3/terraform-launch-config.tfstate"
        dynamodb_table = "terraform-locks-pranav"
        encrypt = true
    }
}