variable "service_account" {
  type = object({
    account_name = string
    namespace    = string
    role_name    = string
    binding_name = string
  })
}