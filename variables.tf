variable "location" {
  description = "The location where the resources should be created"
  type        = string
  default     = "eastus"
}

variable "tenant_id" {
  type      = string
  sensitive = true
}

variable "object_id" {
  type      = string
  sensitive = true
}

variable "adlsg2_name" {
  type = string
}

variable "adlsg2_key" {
  type      = string
  sensitive = true
}

variable "adminuser" {
  type      = string
  sensitive = true
}

variable "password" {
  type      = string
  sensitive = true
}



variable "synapse_workspace_name" {
  type = string
}