variable "azure_subscription_id" {
  description = "The Azure Subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Name for the resource group"
  default     = "rg-postgres"
}

variable "location" {
  default = "West US 3"
}

variable "postgres_admin_username" {
  description = "Username to connect to PostgreSQL"
}

variable "postgress_admin_password" {
  description = "Password to connect to PostgreSQL"
  sensitive   = true
}
