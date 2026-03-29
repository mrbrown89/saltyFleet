# saltyFleet - WIP!!!!!!!

Welcome to my Salty Fleet repo! 

What is it you ask? The purpose of this repo is to give test bed for managing macs with [salt](https://saltproject.io) and use [fleet](https://fleetdm.com) for visibility. The goal is to allow people to clone this repo and be able to have everything up and running quickly including a mac VM for testing. You can then tinkering around with the tools to learn them and to test out something you may want to use in your own environment!

To follow along you'll need:

**Tart**

Tart will be our hypervisor to run a mac VM. We will automate the build of VMs using packer. You can install tart via `brew install cirruslabs/cli/tart`.

**Packer**

Packer can be installed via home brew. Packer will be used to automate the build of macOS VMs.

**Ansible**

You can install Ansible via home brew. We will be using it as part of our packer builds.

**Docker**

We'll be using docker to run a bunch of containers

**fleetctl**

Will be using fleetctl to build fleet. The bootstrap script will install this for you.

**Apparency**

Download and install [Apparency](). We'll need to use this later on to demo installing apps via salt.

## Quick Start Guide

### Step 1 - Boot Strap

Run the bootStrap.sh script in the bootStrap directory. This script will install `fleetctl`, start the fleet container, run some `fleetctl` command to deploy some queries and policies, final the script will build a basic http server which we will use to hold packages for salt to deploy. 

Once the script has run, your default browser will open up to the fleet home page. You will then need to create a mac package. 

### Step 2 - Create a Mac Package

In fleet's interface click on Hosts -> add host. Fleet will give you a command to run with `fleetctl`. 

I prefer to `cd` instal `~/.fleetctl` and then run my command from here:

```
./fleetctl package --type=pkg --enable-scripts --fleet-desktop --fleet-url=https://<macs IP>:8412 --enroll-secret=<secret provider by fleet> --insecure
```

The above example is slight different to what fleet will generate for you. I've changed `localhost` to the IP of my mac and added `--insecure` to my command.

Once fleet has generated the package, move it to `/saltyFleet/ci/packages`.

### Step 3 - Apparency Package

Why Apparency? No idea. Its just the first app in my applications folder and thought I'd use that! 

Download and install Apparency then run:

```
pkgbuild --root /Applications/Apparency.app --identifier com.mothersruin.MRSFoundation --install-location /Applications Apparency.pkg
```

Now copy the package to `/saltyFleet/packages/Apparency`

### Step 4 - Build your Golden VM

We're going to use packer to build a golden VM in tart. We'll clone this vm to be used with fleet later.

`cd` into `/saltyFleet/ci/tart/` and run `packer init` to install the packer plugin. Then run `packer build .`. Now take a break and grab a brew 🫖

### Step 5 - Create the saltyMac VM

Now that packer has completed, `cd` into `/saltyFleet/ci/salting-macOS`. Now clone the golden vm to a new vm called `saltyMac` by running `tart clone tahoe-26.2 saltyMac`. Then run `packer build .` to run the `saltyMac.pkr.hcl` packer file. This will run a bunch of ansible playbooks to set your vm up. 

### Step 6 - Start Your VM

Once step 5 is complete run `tart run saltyMac`. Let the VM load up and login to the desktop with the password `admin`. You'll see macOS notifcations about software that has been deployed. Switch to your browser on your mac and navigate to your fleet instance. Click on hosts and you'll see your mac VM.

Salt will be running a salt call. You can view the log at `/var/log/saltymacs.log`




...and thats about it for the quick start guide! You'll now have a mac VM that is managed by salt with fleet dm providing visibility. You'll see some policies and queries in fleet which provide a starting point into viewing salt with fleet. 

For further documentation, please view the directories in this repo for README files that explain what each component does.
