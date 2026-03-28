packer {
  required_plugins {
    tart = {
      version = ">= 1.16.0"
      source  = "github.com/cirruslabs/tart"
    }
    ansible = {
      version = "~> 1"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

source "tart-cli" "tart" {
  from_ipsw    = "https://updates.cdn-apple.com/2026WinterFCS/fullrestores/122-00766/062A6121-2ABE-45D7-BCB1-72B666B6D2C2/UniversalMac_26.4_25E246_Restore.ipsw"
  vm_name      = "tahoe-26.4"
  cpu_count    = 4
  memory_gb    = 8
  disk_size_gb = 50
  ssh_password = "admin"
  ssh_username = "admin"
  ssh_timeout  = "180s"

  boot_command = [
    "<wait60s><spacebar>",
    "<wait30s>italiano<esc>english<enter>",
    "<wait30s><click 'Select Your Country or Region'><wait5s>united states<leftShiftOn><tab><leftShiftOff><spacebar>",
    "<wait10s><tab><tab><tab><spacebar><tab><tab><spacebar>",
    "<wait10s><leftShiftOn><tab><leftShiftOff><spacebar>",
    "<wait10s><leftShiftOn><tab><leftShiftOff><spacebar>",
    "<wait10s><leftShiftOn><tab><leftShiftOff><spacebar>",
    "<wait10s><tab><tab><tab><tab><tab><tab>Managed via Tart<tab>admin<tab>admin<tab>admin<tab><tab><spacebar><tab><tab><spacebar>",
    "<wait120s><leftAltOn><f5><leftAltOff>",
    "<wait10s><leftShiftOn><tab><leftShiftOff><spacebar>",
    "<wait10s><tab><spacebar>",
    "<wait10s><leftShiftOn><tab><leftShiftOff><spacebar>",
    "<wait10s><tab><spacebar>",
    "<wait10s><leftShiftOn><tab><leftShiftOff><spacebar>",
    "<wait10s><tab><spacebar>",
    "<wait10s><tab><tab><tab>UTC<enter><leftShiftOn><tab><leftShiftOff><spacebar>",
    "<wait10s><leftShiftOn><tab><leftShiftOff><spacebar>",
    "<wait10s><tab><tab><spacebar>",
    "<wait10s><tab><spacebar><leftShiftOn><tab><leftShiftOff><spacebar>",
    "<wait10s><leftShiftOn><tab><tab><leftShiftOff><spacebar>",
    "<wait10s><tab><spacebar>",
    "<wait10s><leftShiftOn><tab><leftShiftOff><spacebar>",
    "<wait10s><tab><tab><spacebar>",
    "<wait30s><spacebar>",
    "<wait10s><leftAltOn><f5><leftAltOff>",
    "<wait10s><leftAltOn><spacebar><leftAltOff>Terminal<wait10s><enter>",
    "<wait10s><wait10s>defaults write NSGlobalDomain AppleKeyboardUIMode -int 3<enter>",
    "<wait10s>open '/System/Applications/System Settings.app'<enter>",
    "<wait10s><leftCtrlOn><f2><leftCtrlOff><right><right><right><down>Sharing<enter>",
    "<wait10s><tab><tab><tab><tab><tab><spacebar>",
    "<wait10s><tab><tab><tab><tab><tab><tab><tab><tab><tab><tab><tab><tab><spacebar>",
    "<wait10s><leftAltOn>q<leftAltOff>",
    "<wait10s>sudo spctl --global-disable<enter>",
    "<wait10s>admin<enter>",
    "<wait10s>open '/System/Applications/System Settings.app'<enter>",
    "<wait10s><leftCtrlOn><f2><leftCtrlOff><right><right><right><down>Privacy & Security<enter>",
    "<wait10s><leftShiftOn><tab><tab><tab><tab><tab><tab><leftShiftOff>",
    "<wait10s><down><wait1s><down><wait1s><enter>",
    "<wait10s>admin<enter>",
    "<wait10s><leftShiftOn><tab><leftShiftOff><wait1s><spacebar>",
    "<wait10s><leftAltOn>q<leftAltOff>",
  ]

  run_extra_args = [
    "--no-audio"
  ]

  create_grace_time  = "30s"
  recovery_partition = "keep"
}

build {
  sources = ["source.tart-cli.tart"]

  provisioner "shell" {
    inline = [
      "echo admin | sudo -S sh -c \"mkdir -p /etc/sudoers.d/; echo 'admin ALL=(ALL) NOPASSWD: ALL' | EDITOR=tee visudo /etc/sudoers.d/admin-nopasswd\"",
    ]
  }

  provisioner "shell" {
    inline = [
      "spctl --status | grep -q 'assessments disabled'"
    ]
  }


  ###################################
  # Ansible provisioners
  ###################################

  provisioner "ansible" {
    playbook_file   = "../../ansible/saltyMacName.yml"
    user            = "admin"
    extra_arguments = ["--extra-vars", "ansible_become_pass=admin"]
  }

}
