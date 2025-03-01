terraform {
  required_version = ">= 1.6.0"
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "=3.0.1-rc6"
    }
  }
}

provider "proxmox" {
  pm_api_url      = "https://192.168.2.110:8006/api2/json"
  pm_tls_insecure = true
  pm_user         = "root@pam"
  pm_password     = "admin"
  pm_debug        = true
  #pm_log_enable = "true"
}