terraform{
    required_providers{
        aws = {
            source = "hashicorp/aws"
        }
    }
}

provider "aws" {
    region = "eu-central-1"
}

resource "aws_instance" "web_server" {
    tags = {
        Name = "simple-web-server"
    }
    vpc_security_group_ids = ["${aws_security_group.instance_ingress_traffic.id}"]
    ami = "ami-065deacbcaac64cf2"
    instance_type = "t2.micro"
    user_data = <<-EOF
                #!/bin/bash
                echo "Hello World!" > index.html
                nohup busybox httpd -f -p 8080 &
                EOF
}

resource "aws_security_group" "instance_ingress_traffic" {
  name = "ingress-web-server"

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "webserver_ip" {
  value = "${aws_instance.web_server.public_ip}"
}