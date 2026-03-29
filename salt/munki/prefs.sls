munki_prefs_software_repo:
  macdefaults.write:
    - name: SoftwareRepoURL
    - domain: /Library/Preferences/ManagedInstalls
    - value: "http://192.168.1.196:8080"
    - vtype: string

munki_prefs_client_id:
  macdefaults.write:
    - name: ClientIdentifier
    - domain: /Library/Preferences/ManagedInstalls
    - value: ""
    - vtype: string

munki_prefs_install_apple_updates:
  macdefaults.write:
    - name: InstallAppleSoftwareUpdates
    - domain: /Library/Preferences/ManagedInstalls
    - value: False
    - vtype: bool

munki_prefs_install_requires_restart:
  macdefaults.write:
    - name: InstallRequiresRestart
    - domain: /Library/Preferences/ManagedInstalls
    - value: False
    - vtype: bool

munki_prefs_suppress_user_notification:
  macdefaults.write:
    - name: SuppressUserNotification
    - domain: /Library/Preferences/ManagedInstalls
    - value: False
    - vtype: bool
