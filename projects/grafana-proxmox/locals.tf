locals {
  shared_config = jsondecode(file(var.shared_config_file))

  selected_proxmox_host = try(local.shared_config.proxmox_hosts[var.proxmox_host_key], null)
  selected_network      = try(local.shared_config.network_profiles[var.network_profile_key], null)

  selected_storage_pools = try(local.selected_proxmox_host.storage_pools, null)
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

check "selected_storage_pool_config_exists" {
  assert {
    condition     = local.selected_storage_pools != null
    error_message = "Selected proxmox host must include storage_pools in shared config."
  }
}

check "selected_storage_pool_keys_exist" {
  assert {
    condition = (
      local.selected_storage_pools != null &&
      try(local.selected_storage_pools.lxc_rootfs, null) != null &&
      try(local.selected_storage_pools.vm_disk, null) != null &&
      try(local.selected_storage_pools.snippets, null) != null
    )
    error_message = "storage_pools must include lxc_rootfs, vm_disk, and snippets keys."
  }
}
