resource "proxmox_vm_qemu" "kube_node" {
  for_each = var.kube_nodes

  name = "${var.kube_node_hostname_prefix}${each.key}"
  vmid = each.value.id

  target_node = data.sops_file.secrets.data["pve.host"]
  agent       = 1

  os_type = "cloud-init"
  clone   = "ubuntu-22.04-cloudimg"

  memory   = each.value.memory
  cores    = each.value.cores
  bootdisk = "scsi0"
  scsihw   = "virtio-scsi-pci"
  onboot   = true

  vga {
    type = "qxl"
  }
  network {
    model   = "virtio"
    macaddr = data.sops_file.secrets.data["k8s.${each.key}.macaddr"]
    bridge  = data.sops_file.secrets.data["pve.bridge_if"]
    tag     = data.sops_file.secrets.data["network.tag"]
  }
  disk {
    type    = "scsi"
    storage = "local-lvm"
    size    = "8G"
    format  = "raw"
    ssd     = 1
    discard = "on"
  }
  serial {
    id   = 0
    type = "socket"
  }
  ipconfig0    = "ip=${data.sops_file.secrets.data["k8s.${each.key}.cidr"]},gw=${data.sops_file.secrets.data["network.gateway"]}"
  ciuser       = data.sops_file.secrets.data["k8s.user"]
  cipassword   = data.sops_file.secrets.data["k8s.user"]
  searchdomain = data.sops_file.secrets.data["network.search_domain"]
  nameserver   = data.sops_file.secrets.data["network.nameserver"]
  sshkeys      = data.sops_file.secrets.data["network.ssh_key"]
}
