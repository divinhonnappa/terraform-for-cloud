variable "cloud_platform" {
    type = list
    description = "select cloud platform - [ aws | azure | google ] where terraform will provision infrastructure and create application"
}

variable "ssh_port"{
    type = number
    default = 22
}

variable "google_firewall_port_ingress" {
    type = list
    default = [
        "22",
        "443",
        "80",
    ]
}

variable "google_firewall_port_egress" {
    type = list
    default = [
        "443",
        "80",
    ]
}

variable "google_ip_source_range_ingress" {
    type = list
    default = ["0.0.0.0/0"]
}

variable "google_ip_source_range_egress" {
    type = list
    default = ["0.0.0.0/0"]
}

variable "google_project_id" {
    type = string
    default = ""
}

variable "google_machine_type"{
    type = string
    default = "n1-standard-1"
}

variable "google_instance_zone" {
    type = string
    default = "us-west1-a"
}

variable "google_instance_key_location" {
    type = string
    default = "google_instance_key"
}

