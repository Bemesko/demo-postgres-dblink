variable "azure_subscription_id" {
  description = "The Azure Subscription ID"
  type        = string
}

variable "resource_group_name" {
  type        = string
  description = "Name for the resource group"
  default     = "rg-postgres-brazilsouth"
}

variable "location" {
  type    = string
  default = "West US 3"
}

variable "postgres_admin_username" {
  type        = string
  description = "Username to connect to PostgreSQL"
}

variable "postgress_admin_password" {
  type        = string
  description = "Password to connect to PostgreSQL"
  sensitive   = true
}
