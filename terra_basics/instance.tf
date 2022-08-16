terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
    }
  }
}
provider "aws" {
    region = "eu-central-1"
}

resource "aws_instance" "example" {
    ami = "ami-065deacbcaac64cf2"
    instance_type = "t2.micro"
    tags = {
        Name = "Example-Terraform"
    }
}