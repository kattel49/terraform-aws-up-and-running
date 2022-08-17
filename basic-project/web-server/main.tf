terraform {
  required_providers{
    aws = {
        source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

variable "instance_name" {
  default = "web-server"
}

resource "aws_security_group" "allow_ssh" {
  name = "allow-ssh"
  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "allow ssh"
    from_port = 22
    protocol = "tcp"
    self = false
    to_port = 22
  }
}

resource "aws_instance" "web-server" {
    instance_type = "t2.micro"
    key_name = "projects"
    ami = "ami-065deacbcaac64cf2"
    tags = {
      "Name" = "${var.instance_name}"
    }
    vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}"]
}

