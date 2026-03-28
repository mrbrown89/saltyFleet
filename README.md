# saltyFleet



Holding pattern:

Step 1 - run bootStrap.sh
Step 2 - login to fleet and copy the command to make a mac package
Step 3 - Make the mac package and put it in `/ci/packages`
Step 4 - One time run - just run the `tahoe-26.2.pkr` file to make the base VM
Step 5 - run `saltyMac.pkr` file to build test vm
Step 6 - run `tart run saltyMac` and nip into fleet to see the status 
