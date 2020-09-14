output "azure_public_ip" {
  value = contains(var.cloud_platform ,"azure") ? data.azurerm_public_ip.demo_azure.ip_address : ""
}