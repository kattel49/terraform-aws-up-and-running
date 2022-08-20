output "launch_config_security_id" {
  value = "${aws_security_group.config_sec_group.id}"
}

output "asg_id" {
  value = "${aws_autoscaling_group.server_autoscale_group.id}"
}

output "lb_ip" {
    value = "${aws_elb.web_server_lb.dns_name}"
}