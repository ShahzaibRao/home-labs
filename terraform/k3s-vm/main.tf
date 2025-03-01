resource "proxmox_vm_qemu" "ansible" {
  name             = count.index == 0 ? "master-node" : "worker-node"
  count            = 2
  target_node      = "pve${count.index + 1}"
  agent            = 1
  cores            = 2
  memory           = 2048
  boot             = "order=scsi0"
  clone            = "debian12-cloudinit"
  full_clone       = true
  scsihw           = "virtio-scsi-single"
  vm_state         = "running"
  automatic_reboot = true

  # Cloud-init Config
  cicustom     = "vendor=local:snippets/qemu-guest-agent.yml"
  ciupgrade    = true
  searchdomain = " "
  ipconfig0    = "ip=192.168.2.${count.index + 180}/24,gw=192.168.2.1"
  skip_ipv6    = true
  ciuser       = "shahzaib"
  cipassword   = "admin"
  sshkeys      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCrE8bZrfwd1FnY5W1j2EK/PicUYp6V0bMAs94EAkxgdr7ot9ANC2F7TrKxSEmjGn8xwRR831PTdQ4KwQi1qRRq5LLGUafBoecfe/ep9ALNHxMRoGPQa70DBIuoGDA7seSdKRtkC5jf0V6nlgro/AQbNbAZ65iWeLoRhZaT2vkBHz5JgNAnfQhAhgNCU4nc2AbBfBaqShNORi7zVQAcK6Yhz0cvrSnc2XiClpzm2RYwQmwY0JM+2Owci2TCnuTfqMEIYw7SwSjrP0+FNXkX+2H+sGgneyshHivD9GP80UTfqlSiFGWjySjpq/gMfjvktikvzZIq1JB2aCMT2xpv50z5lby8f7xOe1uHDb6KSH+x+aBs1K10lfVJ35y9mXZ6uCiZe0BrX1toWMbBlYav2gxlm4NpPMEUpUhzAydTyanWfuMU91ckRIu3mJ1baly/dCDfkOIm+/UTSoX/6T3k95j91N56DM3zFos+tyKQwZJGHB4XZ4dbDGXPJNWWHanuC7Qib6lnLSKoLTarcqtGhujF4yXJ8pcQI1W29DqZeJQC6oXwAgQnFM51HA68p6oIZKkVVOhgQL0095BCmG6HfkpmaQZRckQTsxaZvktLe+Kuybe+qIwILDRI9sAOxaq9W7iZJtAwPpBQ7S0t6P7L1ORKPhsKksiOp/UVCdrXaDPCQw== shahzaib@DESKTOP-GHDJGSH"

  serial {
    id = 0
  }

  disks {
    scsi {
      scsi0 {
        disk {
          storage = "local-lvm"
          size    = "15G"
        }
      }
    }
    ide {
      ide1 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
  }

  network {
    id     = 0
    bridge = "vmbr0"
    model  = "virtio"
  }


}
