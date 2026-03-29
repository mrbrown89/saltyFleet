munki_preferences:
  macdefaults.write:
    - name: SoftwareRepoURL
    - domain: /Library/Preferences/ManagedInstalls
    - value: "http://192.168.1.196"
    - vtype: string

  macdefaults.write:
    - name: ClientIdentifier
    - domain: /Library/Preferences/ManagedInstalls
    - value: "demo-macs"
    - vtype: string

  macdefaults.write:
    - name: InstallAppleSoftwareUpdates
    - domain: /Library/Preferences/ManagedInstalls
    - value: True
    - vtype: bool

  macdefaults.write:
    - name: InstallRequiresRestart
    - domain: /Library/Preferences/ManagedInstalls
    - value: False
    - vtype: bool

  macdefaults.write:
    - name: SuppressUserNotification
    - domain: /Library/Preferences/ManagedInstalls
    - value: False
    - vtype: bool
