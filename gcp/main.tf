module "vm" {
  source       = "./modules/vm"
  region       = var.region
  zone         = var.zone
  machine_type = var.machine_type
}