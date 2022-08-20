output "launch_config_security_id" {
  value = "${aws_security_group.config_sec_group.id}"
}

output "asg_id" {
  value = "${aws_auto_scaling_group.id}"
}