variable "aws_resource_region" {
  default = "eu-central-1"
  description = "Default region for aws region"
}

variable "security_group_name" {
  default = "launch_config_sec"
  description = "Security group for the launch configuration"
}

variable "web_server_machine_type"{
  #free tier
  default = "t2.micro"
  description = "Web Server machine type"
}

variable "web_server_image_type" {
  #free tier ubuntu
  default = "ami-065deacbcaac64cf2"
  description = "Image for the auto scaling group"
}

variable "launch_config_name" {
  default = "Apache2"
  description = "Name of the launch configuration"
}

variable "web_server_asg_name" {
  default = "webserver_asg"
  description = "Name of the auto scaling group"
}

variable "asg_min_size" {
  default = "2"
  description = "Minimum number of launch instances"
}

variable "asg_max_size" {
  default = "3"
  description = "Maximum number of launch instances"
}