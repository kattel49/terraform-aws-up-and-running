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

variable "web_server_name" {
  default = "web-server"
}

variable "jenkins_server_name" {
  default = "jenkins-server"
}
#empty security group
resource "aws_security_group" "allow_ssh" {
  name = "allow_ssh"
}
#ingress rule attached to the security group to allow ssh
resource "aws_security_group_rule" "allow_ssh" {
  type = "ingress"
  from_port = 22
  to_port = 22
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.allow_ssh.id}"
  protocol = "tcp"
}
#web-server instance
resource "aws_instance" "web-server" {
    instance_type = "t2.micro"
    key_name = "projects"
    ami = "ami-065deacbcaac64cf2"
    tags = {
      "Name" = "${var.web_server_name}"
    }
    vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}"]
}
#jenkins-server instance
resource "aws_instance" "jenkins-server" {
  ami = "ami-065deacbcaac64cf2"
  instance_type = "t2.micro"
  key_name = "projects"
  tags = {
    Name = "${var.jenkins_server_name}"
  }
  vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}"]
}
#ip address of the web server
output "web_ip" {
  value = "${aws_instance.web-server.public_ip}"
}
#ip address of the jenkins server
output "jenkins_ip"{
  value = "${aws_instance.jenkins-server.public_ip}"
}