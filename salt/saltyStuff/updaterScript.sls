saltyfleet_runtime_dir:
  file.directory:
    - name: /usr/local/saltyfleet
    - user: root
    - group: wheel
    - mode: '0755'

saltyfleet_update_script:
  file.managed:
    - name: /usr/local/saltyfleet/updatesaltyfleet.zsh
    - source: /opt/saltyfleet/salt/saltyStuff/updatesaltyfleet.zsh
    - user: root
    - group: wheel
    - mode: '0755'
    - require:
      - file: saltyfleet_runtime_dir
