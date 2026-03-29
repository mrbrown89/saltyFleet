# saltyFleet

Welcome to my Salty Fleet repo! 

What is it you ask? The purpose of this repo is to give test bed for managing macs with [salt](https://saltproject.io) and use [fleet](https://fleetdm.com) for visibility. The goal is to allow people to clone this repo and be able to have everything up and running quickly including a mac VM for testing. You can then tinkering around with the tools to learn them and to test out something you may want to use in your own environment!

To follow along you'll need:

**Tart**



**Packer**

**Ansible**

**Docker**

**fleetctl**


## Quick Start Guide









Holding pattern:

Step 1 - run bootStrap.sh
Step 2 - login to fleet and copy the command to make a mac package
Step 3 - Make the mac package and put it in `/ci/packages`
Step 4 - One time run - just run the `tahoe-26.2.pkr` file to make the base VM
Step 5 - run `saltyMac.pkr` file to build test vm
Step 6 - run `tart run saltyMac` and nip into fleet to see the status 
