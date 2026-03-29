# salt/states/apparency.sls
apparency:
  pkg.installed:
    - source: http://192.168.1.196:8080/packages/Apparency.pkg
    - allow_virtual: True
