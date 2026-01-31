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

source "tart-cli" "saltyMac" {
  vm_name      = "saltyMac"
  ssh_username = "Matt"
  ssh_password = "Matt"
  ssh_timeout  = "180s"
}

build {
  sources = ["source.tart-cli.saltyMac"]

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
  
    provisioner "ansible" {
    playbook_file   = "../ansible/shell.yml"
    user            = "Matt"
    extra_arguments = ["--extra-vars", "ansible_become_pass=Matt"]
  }
  
}
