variable "cloud_platform" {
    type = list
    description = "select cloud platform - [ aws | azure | google ] where terraform will provision infrastructure and create application"
}

variable "configure_security_rule" {
  type = map
  default = {
    "SSH" = ["22","1001"]
    "HTTP" = ["80","1002"]
    "HTTPS" = ["443","1003"]
  }
}

variable "azure_virtual_network_address_space" {
    type = list
    default = ["10.0.0.0/16"]
}

variable "azure_subnet_address_prefix" {
    type = string
    default = "10.0.2.0/24"
}

variable "azure_location" {
    type = string
    default = "East US 2"
}

variable "azure_vm_size" {
    type = string
    default = "Standard_DS1_v2"
}

variable "azure_resource_group" {
    type = string
    default = "demo-azure-terraform-resources created on console or using a separate terraform file"
}

variable "azure_demo_image_name"{
    type = string
    default = "azure image id custom created with the application installed"    
}

variable "azure_instance_key_location" {
    type = string
}