variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "tags" {
  type = object({})
}

variable "distinguisher" {
  type = string
}

variable "storage_container_type" {
  type = string
}

variable "storage_container_endpoint" {
  type = string
}

variable "storage_account_name" {
  type = string
}

# variable "storage_authentication_type" {
#   type = string
# }
