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
                echo "<h1>Hello World! from $HOSTNAME</h1>" > /var/www/html/index.html
                systemctl restart apache2
                EOF
    lifecycle {
      create_before_destroy = true
    }
}

data "aws_availability_zones" "all_zones" {}

resource "aws_autoscaling_group" "server_autoscale_group" {
    name = "${var.web_server_asg_name}"
    launch_configuration = "${aws_launch_configuration.web_server_configuration.name}"
    min_size = "${var.asg_min_size}"
    max_size = "${var.asg_max_size}"
    lifecycle {
      create_before_destroy = true
    }
    availability_zones = "${data.aws_availability_zones.all_zones.names}"
    #load_balancers = ["${aws_elb.web_server_lb.id}"] does not work
}

resource "aws_autoscaling_attachment" "elb_attachment" {
    autoscaling_group_name = "${aws_autoscaling_group.server_autoscale_group.id}"
    elb = "${aws_elb.web_server_lb.id}"
}

resource "aws_elb" "web_server_lb" {
    name = "${var.lb_web_server}"
    availability_zones = "${data.aws_availability_zones.all_zones.names}"
    security_groups = ["${aws_security_group.config_sec_group.id}"]
    listener {
      instance_port = 80
      instance_protocol = "http"
      lb_port = 80
      lb_protocol = "http"
    }

    health_check {
      healthy_threshold = "${var.asg_healthy_thresh}"
      unhealthy_threshold = "${var.asg_unhealthy_thresh}"
      timeout = 3
      target = "HTTP:80/"
      interval = 30
    }
    lifecycle {
        create_before_destroy = true
    }
}