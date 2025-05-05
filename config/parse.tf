###############################################################################
# variables.tf
###############################################################################
variable "provider" {
  description = "aws | gcp"
  type        = string
  default     = "aws"
}

variable "config_file" {
  description = "Path to abstract JSON config"
  type        = string
  default     = "${path.module}/config.json"
}

###############################################################################
# locals.tf  – читаємо JSON і готуємо мапи
###############################################################################
locals {
  cfg = jsondecode(file(var.config_file))

  size_map = {
    aws = { small = "t3.micro",  medium = "t3.medium",  large = "t3.large" },
    gcp = { small = "e2-micro", medium = "e2-standard-2", large = "e2-standard-4" }
  }

  image_map = {
    aws = { ubuntu = "ami-02f9ea74049c8a611" },               # Ubuntu 22.04 eu-central-1
    gcp = { ubuntu = "ubuntu-os-cloud/ubuntu-2204-lts" }
  }

  # потрібні VM лише для обраного провайдера
  vms = [
    for vm in local.cfg.vm_instances : vm
    if (var.provider == "aws" && contains(["a","b","c"], vm.zone)) ||
       (var.provider == "gcp" && contains(["a","b","c"], vm.zone))
  ]
}

###############################################################################
# terraform & providers
###############################################################################
terraform {
  required_providers {
    aws    = { source = "hashicorp/aws",    version = "~> 5.0" }
    google = { source = "hashicorp/google", version = "~> 5.0" }
  }
}

# AWS provider (без count!)
provider "aws" {
  alias  = "aws"
  region = "eu-central-1"
  # використовуватиметься лише якщо var.provider == "aws"
}

# GCP provider
provider "google" {
  alias   = "gcp"
  project = "my-gcp-project"
  region  = "europe-west3"
  # використовуватиметься лише якщо var.provider == "gcp"
}

###############################################################################
# ───────────────── AWS ─────────────────
###############################################################################
resource "aws_vpc" "main" {
  count      = var.provider == "aws" ? 1 : 0
  provider   = aws.aws
  cidr_block = local.cfg.network.vpc_cidr
}

resource "aws_subnet" "main" {
  count                    = var.provider == "aws" ? 1 : 0
  provider                 = aws.aws
  vpc_id                   = aws_vpc.main[0].id
  cidr_block               = local.cfg.network.subnets[0].cidr
  map_public_ip_on_launch  = local.cfg.network.subnets[0].public
}

# SG-шаблон для AWS
resource "aws_security_group" "sg" {
  for_each = var.provider == "aws" ? {
    for sg in local.cfg.security_groups : sg.name => sg
  } : {}

  provider    = aws.aws
  name        = each.key
  description = each.value.description
  vpc_id      = aws_vpc.main[0].id

  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      protocol  = ingress.value.protocol
      from_port = ingress.value.port
      to_port   = ingress.value.port

     
      cidr_blocks = try(
        [lookup({ for n in local.cfg.networks : n.name => n.cidr }, ingress.value.source)],
        null
      )
      security_groups = try(
        [aws_security_group.sg[ingress.value.source].id],
        null
      )
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2-інстанси
resource "aws_instance" "vm" {
  for_each = var.provider == "aws" ? {
    for vm in local.vms : vm.name => vm
  } : {}

  provider               = aws.aws
  ami                    = local.image_map.aws[local.cfg.os]
  instance_type          = local.size_map.aws[each.value.size]
  subnet_id              = aws_subnet.main[0].id
  vpc_security_group_ids = [
    for sg in local.cfg.security_groups :
    sg.attach_to != null && contains(sg.attach_to, each.value.name)
    ? aws_security_group.sg[sg.name].id : null
  ]
  tags = { Name = each.key }
}

###############################################################################
# ───────────────── GCP ─────────────────
###############################################################################
resource "google_compute_network" "main" {
  count                   = var.provider == "gcp" ? 1 : 0
  provider                = google.gcp
  name                    = "main-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main" {
  count      = var.provider == "gcp" ? 1 : 0
  provider   = google.gcp
  name       = "main-subnet"
  region     = "europe-west3"
  network    = google_compute_network.main[0].name
  ip_cidr_range = local.cfg.network.subnets[0].cidr
}

# Firewall (аналог SG)
resource "google_compute_firewall" "fw" {
  for_each = var.provider == "gcp" ? {
    for sg in local.cfg.security_groups : sg.name => sg
  } : {}

  provider = google.gcp
  name     = each.key
  network  = google_compute_network.main[0].name

  allow {
    protocol = "tcp"
    ports    = [for r in each.value.ingress : tostring(r.port)]
  }

  source_ranges = [
    for r in each.value.ingress :
    lookup({ for n in local.cfg.networks : n.name => n.cidr }, r.source, r.source)
  ]
}

# Compute-інстанси
resource "google_compute_instance" "vm" {
  count    = var.provider == "gcp" ? length(local.vms) : 0
  provider = google.gcp

  name         = local.vms[count.index].name
  machine_type = local.size_map.gcp[local.vms[count.index].size]
  zone         = "europe-west3-${local.vms[count.index].zone}"

  boot_disk {
    initialize_params {
      image = local.image_map.gcp[local.cfg.os]
    }
  }

  network_interface {
    network    = google_compute_network.main[0].name
    subnetwork = google_compute_subnetwork.main[0].name
    access_config {}              # публічна IP
  }

  tags = local.vms[count.index].tags
}
