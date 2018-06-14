variable "client_id" {}
variable "client_secret" {}

variable "agent_count" {
  default = 3
}

variable "dns_prefix" {
  default = "aksdemo"
}

variable "admin_username" {
    default = "demo"
}

variable cluster_name {
  default = "aksdemo1"
}

variable resource_group_name {
  default = "aksdemo-rg"
}

variable location {
  default = "Central US"
}