# Continuous Integration (CI)

This repo is designed to be tested before it ever touches a real Mac.

Salt states can be deceptively dangerous on macOS — a bad `defaults write`, a broken `cmd.run`, or a misplaced `sudo` can leave a machine in a right mess. CI exists here to catch that before anything runs on a daily driver or production machine.

Also, CI in a VM using Packer is fun!

The goal is simple. If it passes CI, I’m confident applying it for real. Famous last words, right?

I've created packer files for Parallels and Tart. 

---

## What CI Means

CI means:
- building a throwaway macOS VM
- applying Salt states inside that VM
- verifying they converge cleanly and idempotently
- then throwing the VM away

No state is trusted unless it survives this process.

---

##  Tart

[Tart](https://tart.run) 

**Shopping list:**

- Tart
- Packer
- Ansible

You can download all three of the above using brew:

**Tart**

```
brew install cirruslabs/cli/tart
```

**Packer**

```
brew install hashicorp/tap/packer
```

**Ansible**

```
brew install ansible
```

**How it works:**

If this is the first run tart will download the IPSW file that is defined in our source block. Tart caches the download so if you delete the VM that is create and start again you don't have to wait around for the download to complete.

Using the packer file tart will build out a macOS image using the username and password of `Matt` which is the user our salt states are configured to run against. Feel free to change these to whatever you like. The image will be created with 4 CPU cores and 8GB of memory. Packer will also set a VM name. Each time Apple releases a new macOS version you can change the `from_ipsw` variable and the `vm_name` variable to the new version of macOS and rerun the packer file to get a new upto date VM. Cool right! 

In our build section we have a shell provisioner which sets passwordless sudo for the user `Matt`.

Next we have another shell provisioner which checks to see if gatekeeper is disabled by running `spctl`.

Now we have two more shell provisioners which run two scripts. The first install xcode command line tools and the second installs brew.

After that we have our ansible playbooks which:

1. Sets autologin
2. Disables sleep
3. Disables the screen saver
4. Disables spotlight so that spotlight doesn't start indexing stuff


**Running Packer**

First `cd` into the directory holding our packer file `/salting-macOS/CI/tart`. If this is your first ever run then first run `packer init tahoe.pkr.hcl` to download all of the plugins needed. 

Once you have all the plugins then simply run `packer build .`. Tart will then download the IPSW from Apple and will cache it for future use. Next step is very important... go make a cup of tea. 

Once packer has completed, run `tart list`. You'll see your new VM:

```
Source Name                                                                                              Disk Size SizeOnDisk State  
local  tahoe-26.2                                                                                        50   30   30         stopped
```

This is our base image. Now we need to clone it and clone this repo to it. Once thats done we can run the new VM, run our bootstrap script and check our salt stuff works! As a side note, you can clone this base image to use on other projects.

`cd` into `/salting-macOS/CI/salting-macOS` and run `packer build saltyMac.pkr.hcl`.

This packer file will clone the the base image with the same cpu and memory count. This time packer will only run two ansible playbooks which will set the vm name and clone this repo.


---

## Why a VM and Not Containers?

macOS configuration:
- relies heavily on user sessions
- uses per-user plists
- expects launch services, Dock, Finder, etc.

Containers simply don’t model this well.

A real macOS VM behaves like:
- a real user account
- a real Dock
- a real login session

Which makes failures meaningful instead of theoretical.

---

## How States Are Tested

In short: the same way I would on a fresh Mac.

The beauty of using Packer and a golden VM is that we already start from a known-good state:
- the repo is cloned (using Ansible via Packer)
- Xcode Command Line Tools are installed
- Homebrew is installed

This avoids wasting time waiting for installers during every CI run.

Once the VM is up, all that’s left to do is run the `bootStrap.sh` script. This script:
- installs Salt
- applies the Salt states locally

Normally `bootStrap.sh` can also install Xcode tools and Homebrew, but those steps are intentionally pre baked into the golden VM to keep CI runs fast and predictable.

If the states converge cleanly and idempotently here, I’m happy to trust them on a real machine.

---
