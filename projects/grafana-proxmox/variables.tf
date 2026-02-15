variable "shared_config_file" {
  description = "Path to shared JSON config containing proxmox_hosts and network_profiles."
  type        = string
  default     = "../../shared/home-lab.json"
}

variable "proxmox_host_key" {
  description = "Key from shared_config.proxmox_hosts selecting where to deploy this project."
  type        = string
}

variable "network_profile_key" {
  description = "Key from shared_config.network_profiles selecting bridge, gateway, and DNS settings."
  type        = string
  default     = "lan"
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

variable "ip_cidr" {
  description = "CIDR address for the workload network interface (for example 192.168.1.50/24)."
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
