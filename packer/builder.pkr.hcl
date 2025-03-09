packer {
  required_plugins {
    proxmox = {
      version = "v1.2.1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

# Define Variables
variable "proxmox_url" {
  type    = string
  default = "http://192.168.2.110:8006/api2/json"
}

variable "username" {
  type    = string
}

variable "token" {
  type    = string
}

variable "insecure_skip_tls_verify" {
  type    = bool
  default = true
}

variable "ssh_password" {
  type    = string
}

variable "node" {
  type    = string
  default = "pve2"
}

variable "disk_size" {
  type    = string
  default = "10G"  # Reduced from 20G to 10G for a smaller footprint
}

variable "localiso" {
  type    = string
  default = "local:iso/Rocky-9-latest-x86_64-minimal.iso"
}

source "proxmox-iso" "rocky9-light" {
  proxmox_url              = var.proxmox_url
  username                 = var.username
  token                    = var.token
  insecure_skip_tls_verify = var.insecure_skip_tls_verify
  node                     = var.node
  vm_id                    = 1001
  vm_name                  = "rocky9-light"
  template_name            = "rocky-light-template"
  template_description     = "Lightweight Rocky Linux 9.5, optimized"
  ssh_username             = "root"
  ssh_password             = var.ssh_password
  numa                     = false  # Disabled NUMA for simplicity
  cores                    = 1      # Reduced CPU from 2 to 1
  memory                   = 1024   # Reduced RAM from 2048MB to 1024MB
  os                       = "l26"
  qemu_agent               = true
  machine                  = "q35"
  cpu_type                 = "host"
  http_directory           = "http"
  http_port_min            = 8000   # Dynamic range to avoid conflicts
  http_port_max            = 9000
  http_bind_address        = "0.0.0.0"
  communicator             = "none"
  task_timeout             = "10m"
  scsi_controller          = "virtio-scsi-pci"

  # Boot ISO configuration
  boot_iso {
    type     = "scsi"
    iso_file = var.localiso
    unmount  = true
  }

  # Disk configuration (smaller, raw format for performance)
  disks {
    type         = "virtio"
    disk_size    = var.disk_size
    storage_pool = "local-lvm"
    format       = "raw"
  }

  # Network configuration (no firewall, simple network)
  network_adapters {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
  }

  # Boot command for automated Kickstart installation
  boot_command = [
    "<tab>",
    " inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rocky9-ks.cfg",
    " inst.stage2=cdrom",
    " inst.text",
    " ip=dhcp",
    " <enter>",
    " <enter>"
  ]
}

build {
  name    = "rocky-light-template"
  sources = ["source.proxmox-iso.rocky9-light"]
}
