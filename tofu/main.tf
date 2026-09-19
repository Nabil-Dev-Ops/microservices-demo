terraform {
  required_version = ">= 1.6.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.66.0"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_api_url
  api_token = "${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}"
  insecure  = true

  ssh {
    agent    = true
    username = "root"
  }
}

# Download Ubuntu 22.04 Cloud Image onto node-1
resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image_node1" {
  content_type        = "iso"
  datastore_id        = "local"
  node_name           = var.target_node_pve1
  url                 = "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"
  file_name           = "ubuntu-22.04-cloudimg.img"
  verify              = false
  overwrite           = true
  overwrite_unmanaged = true
}

# Download Ubuntu 22.04 Cloud Image onto node-2
resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image_node2" {
  content_type        = "iso"
  datastore_id        = "local"
  node_name           = var.target_node_pve2
  url                 = "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"
  file_name           = "ubuntu-22.04-cloudimg.img"
  verify              = false
  overwrite           = true
  overwrite_unmanaged = true
}

# VM 100: Control Plane (192.168.0.110) on node-1
resource "proxmox_virtual_environment_vm" "k3s_control_plane" {
  name        = "k3s-control-plane"
  description = "K3s Control Plane Node"
  node_name   = var.target_node_pve1
  vm_id       = 100

  agent {
    enabled = true
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 4096
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image_node1.id
    interface    = "scsi0"
    size         = 30
  }

  network_device {
    bridge = "vmbr0"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "192.168.0.110/24"
        gateway = "192.168.0.1"
      }
    }

    user_account {
      username = "ubuntu"
      keys     = [var.ssh_public_key]
    }
  }
}

# VM 101: Worker Node (192.168.0.111) on node-2
resource "proxmox_virtual_environment_vm" "k3s_worker" {
  name        = "k3s-worker"
  description = "K3s Worker Node"
  node_name   = var.target_node_pve2
  vm_id       = 101

  agent {
    enabled = true
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 4096
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image_node2.id
    interface    = "scsi0"
    size         = 30
  }

  network_device {
    bridge = "vmbr0"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "192.168.0.111/24"
        gateway = "192.168.0.1"
      }
    }

    user_account {
      username = "ubuntu"
      keys     = [var.ssh_public_key]
    }
  }
}

output "control_plane_ip" {
  value = "192.168.0.110"
}

output "worker_ip" {
  value = "192.168.0.111"
}