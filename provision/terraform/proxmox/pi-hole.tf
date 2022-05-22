resource "proxmox_lxc" "pi_hole" {
  vmid         = 110
  target_node  = data.sops_file.secrets.data["pve.host"]
  hostname     = "pi-hole"
  ostemplate   = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  password     = data.sops_file.secrets.data["pi_hole.password"]
  unprivileged = true
  onboot       = true
  start        = true

  ssh_public_keys = data.sops_file.secrets.data["network.ssh_key"]
  searchdomain    = data.sops_file.secrets.data["network.search_domain"]
  nameserver      = data.sops_file.secrets.data["network.nameserver"]

  cores  = 1
  memory = 256
  swap   = 512

  rootfs {
    storage = "local-lvm"
    size    = "2G"
  }

  network {
    name   = "eth0"
    bridge = data.sops_file.secrets.data["pve.bridge_if"]
    tag    = data.sops_file.secrets.data["network.tag"]
    gw     = data.sops_file.secrets.data["network.gateway"]
    hwaddr = data.sops_file.secrets.data["pi_hole.macaddr"]
    ip     = data.sops_file.secrets.data["pi_hole.cidr"]
  }

}
