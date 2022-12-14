variable "location" {
  description = "The location where the resources should be created"
  type        = string
  default     = "eastus"
}

variable "adlsg2_key" {
  type      = string
  sensitive = true
}

variable "password" {
  type      = string
  sensitive = true
}

variable "admin" {
  type      = string
  sensitive = true
}

variable "object_id" {
  type      = string
  sensitive = true
}

variable "tenant_id" {
  type      = string
  sensitive = true
}

variable "synapse_workspace_name" {
  type      = string
  sensitive = true
}