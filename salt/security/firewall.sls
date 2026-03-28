enable_firewall:
  cmd.run:
    - name: /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
    - unless: /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate | grep -i "enabled"
    - runas: root

enable_stealth_mode:
  cmd.run:
    - name: /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
    - unless: /usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode | grep -i "on"
    - runas: root
