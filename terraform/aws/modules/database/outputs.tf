output "check_secret_exists_all" {
  value = {
    for id, check in data.external.check_secret_exists :
    id => check.result
  }
}