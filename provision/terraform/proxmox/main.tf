terraform {
  required_version = ">= 0.13.0"
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "2.9.10"
    }

    sops = {
      source = "carlpett/sops"
      version = "0.7.1"
    }
  }
}

data "sops_file" "secrets" {
  source_file = "secrets.sops.yaml"
}

provider "proxmox" {
    pm_api_url = data.sops_file.secrets.data["pve.api_url"]
    pm_user =  data.sops_file.secrets.data["pve.user"]
    pm_password = data.sops_file.secrets.data["pve.password"]
    pm_parallel = 6
}

provider "sops" {}
