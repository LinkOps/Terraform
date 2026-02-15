locals {
  shared_config = jsondecode(file(var.shared_config_file))

  selected_proxmox_host = try(local.shared_config.proxmox_hosts[var.proxmox_host_key], null)
  selected_network      = try(local.shared_config.network_profiles[var.network_profile_key], null)
}

check "selected_proxmox_host_exists" {
  assert {
    condition     = local.selected_proxmox_host != null
    error_message = "proxmox_host_key not found in shared config proxmox_hosts."
  }
}

check "selected_network_profile_exists" {
  assert {
    condition     = local.selected_network != null
    error_message = "network_profile_key not found in shared config network_profiles."
  }
}
