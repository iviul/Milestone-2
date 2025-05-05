variable "vm_config" { }

variable "vpc_id" {
    type = string
}

variable "subnet_ids_by_name" {
    type = map(string)
}