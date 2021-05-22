resource "proxmox_vm_qemu" "kube-master" {
  for_each = var.masters

  name        = each.key
  target_node = each.value.target_node
  agent       = 1
  clone       = "${each.value.target_node}-${var.common.clone}"
  vmid        = each.value.id
  memory      = each.value.memory
  cores       = each.value.cores
  vga {
    type = "qxl"
  }
  network {
    model    = "virtio"
    macaddr  = each.value.macaddr
    bridge   = "vmbr0"
    tag      = 22
    firewall = true
  }
  disk {
    type    = "scsi"
    storage = "local-lvm"
    size    = each.value.disk
    format  = "raw"
    ssd     = 1
    discard = "on"
  }
  serial {
    id = 0
    type = "socket"
  }
  bootdisk     = "scsi0"
  scsihw       = "virtio-scsi-pci"
  os_type      = "cloud-init"
  ipconfig0    = "ip=${each.value.cidr},gw=${each.value.gw}"
  ciuser       = "root"
  searchdomain = var.common.search_domain
  nameserver   = var.common.nameserver
  sshkeys      = data.sops_file.secrets.data["k3s.ssh_key"]
}
