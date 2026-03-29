munki_check_daemon:
  file.managed:
    - name: /Library/LaunchDaemons/com.googlecode.munki.managedsoftwareupdate-check.plist
    - source: salt://munki/plists/com.googlecode.munki.managedsoftwareupdate-check.plist
    - user: root
    - group: wheel
    - mode: '0644'
    - require:
      - pkg: munki

reload_munki_check_daemon:
  cmd.run:
    - name: |
        if /bin/launchctl print system/com.googlecode.munki.managedsoftwareupdate-check >/dev/null 2>&1; then
          /bin/launchctl bootout system /Library/LaunchDaemons/com.googlecode.munki.managedsoftwareupdate-check.plist
        fi
        /bin/launchctl bootstrap system /Library/LaunchDaemons/com.googlecode.munki.managedsoftwareupdate-check.plist
    - require:
      - file: munki_check_daemon
