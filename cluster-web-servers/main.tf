terraform{
    required_providers {
      aws = {
        source = "hashicorp/aws"
      }
    }
}

provider "aws"{
    region = "${var.aws_resource_region}"
}

resource "aws_security_group" "config_sec_group" {
    name = "${var.security_group_name}"
    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_security_group_rule" "allow_ssh" {
    type = "ingress"
    from_port = 22
    to_port = 22
    security_group_id = "${aws_security_group.config_sec_group.id}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_security_group_rule" "allow_http" {
    type = "ingress"
    from_port = 80
    to_port = 80
    security_group_id = "${aws_security_group.config_sec_group.id}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    lifecycle {
      create_before_destroy = true
    }
}
#allow for internet connection for initial setup
resource "aws_security_group_rule" "allow_egress" {
    type = "egress"
    from_port = 0
    to_port = 65535
    security_group_id = "${aws_security_group.config_sec_group.id}"
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_launch_configuration" "web_server_configuration" {
    instance_type = "${var.web_server_machine_type}"
    name = "${var.launch_config_name}"
    image_id = "${var.web_server_image_type}"
    security_groups = ["${aws_security_group.config_sec_group.id}"]
    key_name = "projects"
    user_data =<<-EOF
                #!/bin/bash
                apt update -y
                apt install apache2 -y
                systemctl restart apache2
                EOF
    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "server_autoscale_group" {
    name = "${var.web_server_asg_name}"
    launch_configuration = "${aws_launch_configuration.web_server_configuration.name}"
    min_size = "${var.asg_min_size}"
    max_size = "${var.asg_max_size}"
    lifecycle {
      create_before_destroy = true
    }
}