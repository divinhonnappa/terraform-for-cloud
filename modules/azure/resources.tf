locals {
    is_azure = contains(var.cloud_platform ,"azure") ? 1 : 0
}

provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = "=2.5.0"
  features {}
  
  subscription_id = var.azure_subscription_id
  tenant_id = var.azure_tenant_id
  client_id = var.azure_client_id
  client_secret = var.azure_client_secret
}

resource "azurerm_virtual_network" "demo_terraform" {
  count = local.is_azure
  name                = "demo-azure-virtual_network"
  address_space       = var.azure_virtual_network_address_space
  location            = var.azure_location
  resource_group_name = var.azure_resource_group
}

resource "azurerm_subnet" "demo_terraform" {
  count = local.is_azure
  name                 = "demo-azure-subnet"
  resource_group_name  = var.azure_resource_group
  virtual_network_name = azurerm_virtual_network.demo_terraform[0].name
  address_prefix       = var.azure_subnet_address_prefix
}

resource "azurerm_public_ip" "demo_terraform_public_ip" {
    count = local.is_azure
    name                         = "demo-azure-public-ip"
    location                     = var.azure_location
    resource_group_name          = var.azure_resource_group
    allocation_method            = "Dynamic"
}

resource "azurerm_network_security_group" "demo_terraform" {
    count = local.is_azure
    name                = "azure-network-security"
    location            = var.azure_location
    resource_group_name = var.azure_resource_group
    
    security_rule {
        access                     = "Allow"
        direction                  = "Inbound"
        name                       = "Traffic"
        priority                   = 1001
        protocol                   = "Tcp"
        source_port_range          = "*"
        source_address_prefix      = "*"
        destination_port_range     = "*"
        destination_address_prefix = "*"
    }
    
    security_rule {
        access                     = "Allow"
        direction                  = "Outbound"
        name                       = "tls"
        priority                   = 100
        protocol                   = "Tcp"
        source_port_range          = "*"
        source_address_prefix      = "*"
        destination_port_range     = "*"
        destination_address_prefix = "*"
  }
}


resource "azurerm_network_interface" "demo_terraform" {
  count = local.is_azure
  name                = "demo-azure-ni"
  location            = var.azure_location
  resource_group_name = var.azure_resource_group

  ip_configuration {
    name                          = "azure-ni-ip-configuration"
    subnet_id                     = azurerm_subnet.demo_terraform[0].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.demo_terraform_public_ip[0].id
  }
}

resource "azurerm_network_interface_security_group_association" "demo-terraform" {
    count = local.is_azure
    depends_on = [azurerm_network_interface.demo_terraform, azurerm_network_security_group.demo_terraform]
    network_interface_id      = azurerm_network_interface.demo_terraform[0].id
    network_security_group_id = azurerm_network_security_group.demo_terraform[0].id
}

data "azurerm_image" "search" {
  name                = var.azure_demo_image_name
  resource_group_name = var.azure_resource_group
}

resource "azurerm_virtual_machine" "demo_terraform_vm" {
  count = local.is_azure
  name                  = "demo-vm"
  location              = var.azure_location
  resource_group_name   = var.azure_resource_group
  
  vm_size               = var.azure_vm_size

  network_interface_ids = [
      azurerm_network_interface.demo_terraform[0].id,
      ]

  storage_image_reference {
    id = data.azurerm_image.search.id
  }
 
  storage_os_disk {
    name              = "demo-vm-terraform-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = "100"
    os_type           = "linux"
  }

  os_profile {
    computer_name  = "demo-vm"
    admin_username = "ubuntu"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/ubuntu/.ssh/authorized_keys"
      key_data = file(var.azure_instance_key_location)
    }
  }
}


resource "time_sleep" "azure_wait_30_seconds" {
  count = local.is_azure
  depends_on = [azurerm_virtual_machine.demo_terraform_vm]
  create_duration = "30s"
}



resource "null_resource" "start_azure_application" {
  count = local.is_azure
  depends_on = [time_sleep.azure_wait_30_seconds]
  connection {
    type  = "ssh"
    host  =  data.azurerm_public_ip.demo_azure.ip_address
    user  = "ubuntu"
    private_key = file(var.azure_instance_key_location)
    port  = "22"
  }

  provisioner "local-exec" {
    command = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${var.azure_instance_key_location} ubuntu@${data.azurerm_public_ip.demo_azure.ip_address} 'sudo python3 /home/ubuntu/app/demoapp.py azure  2>&1 >& output.log &'"
    interpreter = ["bash", "-c"]
  }
}

data "azurerm_public_ip" "demo_azure" {
  depends_on = [azurerm_public_ip.demo_terraform_public_ip]
  name                = azurerm_public_ip.demo_terraform_public_ip[0].name
  resource_group_name = var.azure_resource_group
}