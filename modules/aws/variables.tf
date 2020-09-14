variable "cloud_platform" {
    type = list
    description = "select cloud platform - [ aws | azure | google ] where terraform will provision infrastructure and create application"
}

variable "aws_vpc_cidr" {
    type = string
    description = "cidr block for aws instance"
    default     = "10.0.0.0/16"
}

variable "aws_subnet_cidr" {
    type = string
    description = "cidr block for aws instance"
    default     = "10.0.1.0/24"
}

variable "aws_instance_count" {
    type = number
    default = 0
    description = "number of aws instances"
}



variable "aws_instance_type" {
    type = string
    default     = "t2.micro"
    description = "type of aws instance to be provisioned"
}

variable "aws_instances_ami" {
    type = string
    default     = "ami image id custom created with the application installed"
    description = "ami used to provision aws instances"
}

variable "configure_ingress" {
  description = "Allow Ec2 ports to accept outside traffic"
  type        = list
  default     = ["80", "443", "22"]
}

variable "aws_instance_key_location" {
    type = string
    default = "location of ssh key. Can be created in aws console"
}