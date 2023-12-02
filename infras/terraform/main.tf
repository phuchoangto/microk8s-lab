# Define locals for variables
locals {
    project_name    = "microk8s-lab"
    admin_username  = "adminuser"
    admin_password  = "Password1234!"
    vm_size         = "Standard_D2s_v3"
}

# Provider configuration for Azure
provider "azurerm" {
    features {}
}

# Resource group
resource "azurerm_resource_group" "rg" {
    name     = local.project_name
    location = "East US"
}

# Virtual network
resource "azurerm_virtual_network" "vnet" {
    name                = "${local.project_name}-vnet"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}

# Subnet
resource "azurerm_subnet" "subnet" {
    name                 = "${local.project_name}-subnet"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = ["10.0.1.0/24"]
}

# Public IP for master VM
resource "azurerm_public_ip" "master_public_ip" {
    name                = "${local.project_name}-master-public-ip"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method   = "Static"
}

# Master NIC
resource "azurerm_network_interface" "master_nic" {
    name                      = "${local.project_name}-master-nic"
    location                  = azurerm_resource_group.rg.location
    resource_group_name       = azurerm_resource_group.rg.name
    ip_configuration {
        name                          = "${local.project_name}-master-ipconfig"
        subnet_id                     = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.master_public_ip.id
    }
}

# Master VM
resource "azurerm_virtual_machine" "master_vm" {
    name                  = "${local.project_name}-master-vm"
    location              = azurerm_resource_group.rg.location
    resource_group_name   = azurerm_resource_group.rg.name
    network_interface_ids = [azurerm_network_interface.master_nic.id]
    vm_size               = local.vm_size

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    storage_os_disk {
        name              = "${local.project_name}-master-osdisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    os_profile {
        computer_name  = "${local.project_name}-master-vm"
        admin_username = local.admin_username
        admin_password = local.admin_password
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }
}

# Public IP for worker VM
resource "azurerm_public_ip" "worker_public_ip" {
    name                = "${local.project_name}-worker-public-ip"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method   = "Static"
}

# Worker NIC
resource "azurerm_network_interface" "worker_nic" {
    name                      = "${local.project_name}-worker-nic"
    location                  = azurerm_resource_group.rg.location
    resource_group_name       = azurerm_resource_group.rg.name
    ip_configuration {
        name                          = "${local.project_name}-worker-ipconfig"
        subnet_id                     = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.worker_public_ip.id
    }
}

# Worker VM
resource "azurerm_virtual_machine" "worker_vm" {
    name                  = "${local.project_name}-worker-vm"
    location              = azurerm_resource_group.rg.location
    resource_group_name   = azurerm_resource_group.rg.name
    network_interface_ids = [azurerm_network_interface.worker_nic.id]
    vm_size               = local.vm_size

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    storage_os_disk {
        name              = "${local.project_name}-worker-osdisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    os_profile {
        computer_name  = "${local.project_name}-worker-vm"
        admin_username = local.admin_username
        admin_password = local.admin_password
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }
}

# Output the public IP of the master VM
output "master_public_ip" {
    value = azurerm_public_ip.master_public_ip.ip_address
}

# Output the public IP of the worker VM
output "worker_public_ip" {
    value = azurerm_public_ip.worker_public_ip.ip_address
}