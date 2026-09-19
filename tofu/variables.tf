variable "proxmox_api_url" {
  type        = string
  description = "Proxmox API Endpoint URL"
}

variable "proxmox_api_token_id" {
  type        = string
  description = "Proxmox API Token ID"
  sensitive   = true
}

variable "proxmox_api_token_secret" {
  type        = string
  description = "Proxmox API Token Secret UUID"
  sensitive   = true
}

variable "target_node_pve1" {
  type        = string
  default     = "node-1"
  description = "Name of first Proxmox Node (192.168.0.100)"
}

variable "target_node_pve2" {
  type        = string
  default     = "node-2"
  description = "Name of second Proxmox Node (192.168.0.101)"
}

variable "ssh_public_key" {
  type        = string
  description = "Public SSH key for VM access"
}