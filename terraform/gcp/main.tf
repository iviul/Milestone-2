locals {
  config = jsondecode(file("${path.module}/../../config/config.json"))["project"]
}

terraform {
  backend "gcs" {}
}
