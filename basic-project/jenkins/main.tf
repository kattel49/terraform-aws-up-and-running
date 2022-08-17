terraform{
    required_providers {
      aws = {
        source = "hashicorp/aws"
      }
    }
}

provider "aws" {
  region = "eu-central-1"
}

variable "instance_name" {
  default = "jenkins-server"
}

resource "aws_instance" "jenkins-server" {
  ami = "ami-065deacbcaac64cf2"
  instance_type = "t2.micro"
  key_name = "projects"
  tags = {
    Name = "${var.instance_name}"
  }
}