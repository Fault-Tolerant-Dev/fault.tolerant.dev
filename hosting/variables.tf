variable "project_id" {
  type = string
}

variable "project_services" {
  type = set(string)
}

variable "region" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "sub_domain_name" {
  type = string
}