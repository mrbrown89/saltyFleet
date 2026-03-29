munki_check:
  macdefaults.write:
    - name: StartInterval
    - domain: /Library/Preferences/com.googlecode.munki.managedsoftwareupdate-install
    - value: 300
    - vtype: int
