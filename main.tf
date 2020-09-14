module "aws_application" {
  source         = "./modules/aws"
  cloud_platform = var.cloud_platform
}

module "google_application" {
  source            = "./modules/google"
  cloud_platform    = var.cloud_platform
  google_project_id = var.google_project_id
}

module "azure_application" {
  source            = "./modules/azure"
  cloud_platform    = var.cloud_platform
}

