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

# -----------------------------
# Source: Clone the existing VM
# -----------------------------
source "tart-cli" "saltyMac" {
  # Name of the VM to clone
  clone_from  = "tahoe-26.2"
  vm_name     = "saltyMac"

  # SSH credentials (must match the user in the source VM)
  ssh_username = "Matt"
  ssh_password = "Matt"

  # Optional: adjust resources if you want different CPU/memory/disk
  cpu_count    = 4
  memory_gb    = 8
  disk_size_gb = 50

  # Optional: give VM a few seconds to finish setup before Packer connects
  ssh_timeout = "180s"

  # Optional: extra args to VM launch
  run_extra_args = ["--no-audio"]
}

# -----------------------------
# Build block
# -----------------------------
build {
  sources = ["source.tart-cli.saltyMac"]

  # -----------------------------
  # Ansible provisioners
  # -----------------------------
  provisioner "ansible" {
    playbook_file   = "../ansible/saltyMacName.yml"
    user            = "Matt"
    extra_arguments = ["--extra-vars", "ansible_become_pass=admin"]
  }

  provisioner "ansible" {
    playbook_file   = "../ansible/cloneRepo.yml"
    user            = "Matt"
    extra_arguments = ["--extra-vars", "ansible_become_pass=Matt"]
  }
}
