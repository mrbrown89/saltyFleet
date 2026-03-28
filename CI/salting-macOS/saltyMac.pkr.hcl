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
  ssh_username = "admin"
  ssh_password = "admin"
  ssh_timeout  = "180s"
}

build {
  sources = ["source.tart-cli.saltyMac"]

  provisioner "ansible" {
    playbook_file   = "../ansible/saltyMacName.yml"
    user            = "admin"
    extra_arguments = ["--extra-vars", "ansible_become_pass=admin"]
  }
  
  provisioner "ansible" {
    playbook_file   = "../ansible/saltPackage.yml"
    user            = "admin"
    extra_arguments = ["--extra-vars", "ansible_become_pass=admin"]
  }

  provisioner "ansible" {
    playbook_file   = "../ansible/munkiPackage.yml"
    user            = "admin"
    extra_arguments = ["--extra-vars", "ansible_become_pass=admin"]
  }

  provisioner "ansible" {
    playbook_file   = "../ansible/fleetPackage.yml"
    user            = "admin"
    extra_arguments = ["--extra-vars", "ansible_become_pass=admin"]
  }
  
    provisioner "ansible" {
    playbook_file   = "../ansible/shell.yml"
    user            = "admin"
    extra_arguments = ["--extra-vars", "ansible_become_pass=admin"]
  }
  
provisioner "shell" {
  script = "../scripts/saltyMacs.sh"
  execute_command = "sudo zsh '{{ .Path }}'"
}
  
}
