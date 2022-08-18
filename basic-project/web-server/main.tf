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
#egress rule for the instance to connect to the internet
resource "aws_security_group_rule" "allow_outbound_traffic" {
  type = "egress"
  from_port = 0
  to_port = 65535
  cidr_blocks = ["0.0.0.0/0"]
  protocol = "-1"
  security_group_id = "${aws_security_group.allow_ssh.id}"
}

resource "aws_security_group" "allow_jenkins" {
  name = "allow_jenkins"
}

resource "aws_security_group_rule" "allow_jenkins" {
  type = "ingress"
  from_port = 8080
  to_port = 8080
  cidr_blocks = ["0.0.0.0/0"]
  protocol = "tcp"
  security_group_id = "${aws_security_group.allow_jenkins.id}"
}

resource "aws_security_group" "allow_http" {
  name = "allow_http"
}

resource "aws_security_group_rule" "allow_http" {
  type = "ingress"
  from_port = 80
  to_port = 80
  cidr_blocks = ["0.0.0.0/0"]
  protocol = "tcp"
  security_group_id = "${aws_security_group.allow_http.id}"
}

#web-server instance
resource "aws_instance" "web-server" {
    instance_type = "t2.micro"
    key_name = "projects"
    ami = "ami-065deacbcaac64cf2"
    tags = {
      "Name" = "${var.web_server_name}"
    }
    vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}", "${aws_security_group.allow_http.id}"]
}
#jenkins-server instance
resource "aws_instance" "jenkins-server" {
  ami = "ami-065deacbcaac64cf2"
  instance_type = "t2.micro"
  key_name = "projects"
  tags = {
    Name = "${var.jenkins_server_name}"
  }
  vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}", "${aws_security_group.allow_jenkins.id}"]
}
#ip address of the web server
output "web_ip" {
  value = "${aws_instance.web-server.public_ip}"
}
#ip address of the jenkins server
output "jenkins_ip"{
  value = "${aws_instance.jenkins-server.public_ip}"
}