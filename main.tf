resource "azurerm_resource_group" "postgres" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "postgres" {
  name                = "postgres-vnet"
  address_space       = ["10.0.10.0/24"]
  location            = azurerm_resource_group.postgres.location
  resource_group_name = azurerm_resource_group.postgres.name
}

resource "azurerm_subnet" "postgres" {
  name                 = "postgres-subnet"
  resource_group_name  = azurerm_resource_group.postgres.name
  virtual_network_name = azurerm_virtual_network.postgres.name
  address_prefixes     = ["10.0.10.0/26"]
}

resource "azurerm_network_security_group" "postgres" {
  name                = "postgres-nsg"
  location            = azurerm_resource_group.postgres.location
  resource_group_name = azurerm_resource_group.postgres.name
}

resource "azurerm_network_security_rule" "allow_postgres" {
  name                        = "allow_postgres"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5432"
  source_address_prefix       = "*" # Allow connections from any IP
  destination_address_prefix  = azurerm_network_interface.postgres.private_ip_address
  resource_group_name         = azurerm_resource_group.postgres.name
  network_security_group_name = azurerm_network_security_group.postgres.name
}

resource "azurerm_postgresql_flexible_server" "postgres" {
  name                   = "postgres-berb-001"
  resource_group_name    = azurerm_resource_group.postgres.name
  location               = azurerm_resource_group.postgres.location
  version                = "12"
  administrator_login    = var.postgres_admin_username
  administrator_password = var.postgress_admin_password

  storage_mb = 32768           # 32 GB storage
  sku_name   = "Standard_B1ms" # Basic tier with minimum configuration

  public_network_access_enabled = true
}

resource "azurerm_network_interface" "postgres" {
  name                = "postgres-nic"
  location            = azurerm_resource_group.postgres.location
  resource_group_name = azurerm_resource_group.postgres.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.postgres.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "postgres" {
  name                  = "postgres-vm"
  location              = azurerm_resource_group.postgres.location
  resource_group_name   = azurerm_resource_group.postgres.name
  network_interface_ids = [azurerm_network_interface.postgres.id]
  vm_size               = "Standard_B2s" # Basic tier, cost-effective VM size

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "postgres-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = var.postgres_admin_username
    admin_password = var.postgress_admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

# Outputs
output "vm_private_ip" {
  description = "Private IP address of the VM"
  value       = azurerm_network_interface.postgres.private_ip_address
}

output "postgres_private_ip" {
  description = "Private IP address of the PostgreSQL server"
  value       = azurerm_postgresql_flexible_server.postgres.private_dns_zone_id
}

output "admin_username" {
  description = "Admin username for the VM"
  value       = var.postgres_admin_username
}

output "admin_password" {
  description = "Admin password for the VM"
  value       = var.postgress_admin_password
  sensitive   = true
}
