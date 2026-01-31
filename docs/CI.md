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



**Running Packer**


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
