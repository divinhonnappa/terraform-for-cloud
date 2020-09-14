variable "cloud_platform" {
  type        = list
  description = "select cloud platform - [ aws | azure | google ] where terraform will provision infrastructure and create application"
}

# aws credentials variables
variable "aws_access_key" {
  default = ""
}
variable "aws_secret_key" {
  default = ""
}
variable "aws_region" {
  default = "us-east-2"
}


# azure credentials variables
variable "azure_subscription_id" {
  default     = ""
}
variable "azure_tenant_id" {
  default = ""
}
variable "azure_client_id" {
  default = ""
}
variable "azure_client_secret" {
  default = ""
}

# google credentials variables
variable "google_credentials_file" {
  default = ""
}
variable "google_project_id" {
  default = ""
}
variable "google_region" {
  default = ""
}

