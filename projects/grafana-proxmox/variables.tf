variable "pm_api_url" {
  description = "Proxmox API URL (for example: https://pve.local:8006/api2/json)."
  type        = string
}

variable "pm_api_token_id" {
  description = "Proxmox API token ID in the format user@realm!tokenid."
  type        = string
}

variable "pm_api_token_secret" {
  description = "Proxmox API token secret."
  type        = string
  sensitive   = true
}

variable "pm_tls_insecure" {
  description = "Set true only if your Proxmox API uses a self-signed certificate."
  type        = bool
  default     = true
}

variable "target_node" {
  description = "Proxmox node that will host Grafana."
  type        = string
}

variable "deployment_mode" {
  description = "Use lxc for Proxmox container (preferred) or vm if your environment cannot run Grafana in LXC."
  type        = string
  default     = "lxc"

  validation {
    condition     = contains(["lxc", "vm"], var.deployment_mode)
    error_message = "deployment_mode must be either 'lxc' or 'vm'."
  }
}

variable "lxc_template" {
  description = "Storage volume of the downloaded LXC template."
  type        = string
  default     = "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
}

variable "lxc_vmid" {
  description = "VMID for the Grafana LXC instance."
  type        = number
  default     = 3010
}

variable "vm_vmid" {
  description = "VMID for the Grafana VM fallback."
  type        = number
  default     = 3011
}

variable "hostname" {
  description = "Hostname for the Grafana workload."
  type        = string
  default     = "grafana"
}

variable "bridge" {
  description = "Proxmox network bridge (for example vmbr0)."
  type        = string
  default     = "vmbr0"
}

variable "ip_cidr" {
  description = "CIDR address for the workload network interface (for example 192.168.1.50/24)."
  type        = string
}

variable "gateway" {
  description = "Default gateway for the Grafana workload."
  type        = string
}

variable "nameserver" {
  description = "DNS nameserver IP for the Grafana workload."
  type        = string
}

variable "root_password" {
  description = "Root password used for initial LXC access and provisioning."
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key copied to root inside LXC/VM."
  type        = string
}

variable "storage" {
  description = "Storage target for disk volumes."
  type        = string
  default     = "local-lvm"
}

variable "disk_size_gb" {
  description = "Disk size in GB."
  type        = number
  default     = 16
}

variable "memory_mb" {
  description = "Memory allocation in MB."
  type        = number
  default     = 2048
}

variable "cores" {
  description = "CPU cores allocation."
  type        = number
  default     = 2
}

variable "vm_clone_template" {
  description = "Name of a cloud-init capable template VM for fallback mode."
  type        = string
  default     = "ubuntu-2404-cloudinit-template"
}
