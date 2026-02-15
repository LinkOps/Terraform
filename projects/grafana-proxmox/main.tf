resource "proxmox_lxc" "grafana" {
  count       = var.deployment_mode == "lxc" ? 1 : 0
  target_node = var.target_node
  vmid        = var.lxc_vmid
  hostname    = var.hostname

  ostemplate    = var.lxc_template
  password      = var.root_password
  unprivileged  = true
  start         = true
  onboot        = true
  cores         = var.cores
  memory        = var.memory_mb
  swap          = 512
  nameserver    = var.nameserver
  searchdomain  = "local"
  ssh_public_keys = var.ssh_public_key

  rootfs {
    storage = var.storage
    size    = "${var.disk_size_gb}G"
  }

  network {
    name   = "eth0"
    bridge = var.bridge
    ip     = var.ip_cidr
    gw     = var.gateway
  }

  features {
    nesting = true
    keyctl  = true
  }
}

resource "null_resource" "install_grafana_lxc" {
  count = var.deployment_mode == "lxc" ? 1 : 0

  triggers = {
    lxc_id = proxmox_lxc.grafana[0].id
  }

  connection {
    type     = "ssh"
    host     = split("/", var.ip_cidr)[0]
    user     = "root"
    password = var.root_password
    timeout  = "10m"
  }

  provisioner "remote-exec" {
    inline = [
      "set -euxo pipefail",
      "apt-get update",
      "apt-get install -y apt-transport-https software-properties-common wget",
      "mkdir -p /etc/apt/keyrings",
      "wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor -o /etc/apt/keyrings/grafana.gpg",
      "echo 'deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main' > /etc/apt/sources.list.d/grafana.list",
      "apt-get update",
      "apt-get install -y grafana",
      "systemctl daemon-reload",
      "systemctl enable --now grafana-server"
    ]
  }
}

resource "proxmox_vm_qemu" "grafana" {
  count       = var.deployment_mode == "vm" ? 1 : 0
  target_node = var.target_node
  vmid        = var.vm_vmid
  name        = "${var.hostname}-vm"
  clone       = var.vm_clone_template
  onboot      = true

  cores   = var.cores
  memory  = var.memory_mb
  scsihw  = "virtio-scsi-pci"
  agent   = 1
  os_type = "cloud-init"

  disk {
    type    = "scsi"
    storage = var.storage
    size    = "${var.disk_size_gb}G"
  }

  network {
    model  = "virtio"
    bridge = var.bridge
  }

  ipconfig0 = "ip=${var.ip_cidr},gw=${var.gateway}"
  nameserver = var.nameserver
  sshkeys    = var.ssh_public_key

  ciuser     = "ubuntu"
  cipassword = var.root_password

  cicustom = "user=local:snippets/grafana-cloud-init.yaml"
}
