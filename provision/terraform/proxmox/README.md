## Create cloudinit template
- Reference for the exact commands were taken from [this great guide](https://austinsnerdythings.com/2021/08/30/how-to-create-a-proxmox-ubuntu-cloud-init-image/).
- Currently, ubuntu just launched it's latest lts release (jammy something 22.04), but make sure to always check for the latest release and replace appropriately
- Also make sure to use the correct pve storage pool (we're using lvm instead of zfs - which is what the guide shows)
- That's the relevant part of the bash history:

```bash
sudo wget --content-disposition https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
sudo apt update -y && sudo apt install libguestfs-tools -y
sudo virt-customize -a jammy-server-cloudimg-amd64.img --install qemu-guest-agent
sudo qm create 9000 --name ubuntu-22.04-cloudimg --memory 2048 --cores 2 --net0 virtio,bridge=${HOST_BRIDGE_IF},tag=${VLAN_TAG} # the last tag part will only be required if you use vlan tagging in your network
sudo qm importdisk 9000 jammy-server-cloudimg-amd64.img local-lvm
sudo qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
sudo qm set 9000 --boot c --bootdisk scsi0
sudo qm set 9000 --ide2 local-lvm:cloudinit
sudo qm set 9000 --serial0 socket --vga serial0
sudo qm set 9000 --agent enabled=1
sudo qm template 9000
```

## encrypting with age
- the $SOPS_AGE_KEY_FILE is used to indicate to terraform where to locate the key used to encrypt the data
- first check if you have something there (should be at `~/.config/sops/age/keys.txt`)
- if, the file exists, get the public key from it
- otherwise, make sure the variable is set and create a new key with:

```bash
age-keygen -o $SOPS_AGE_KEY_FILE
```

### Editing secrets
- To add or edit secrets, there are 2 options:
  - manual -> create a regular yaml file, add the keys with respective secrets in it, save it and run the encryption command
```bash
sops --encrypt --age ${AGE_PUBLIC_KEY} secrets.yaml > secrets.sops.yaml
```

  - automatic -> thanks to the template repo setup (check `.sops.yaml` file in the root dir), we can simply use the sops command:
```bash
sops provision/secrets.sops.yaml
```
    - this will open a new file with some template variables using the editor defined in the environment (`$EDITOR`)
    - you can add the secrets to this file regularly as if you were editing a regular file
    - when you save and close, sops will automatically encrypt that so the unencrypted file won't hang around (and you won't need to add it to `.gitignore` or anything like that)
