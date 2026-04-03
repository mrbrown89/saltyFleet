saltymacs_runtime_dir:
  file.directory:
    - name: /usr/local/saltymacs
    - user: root
    - group: wheel
    - mode: '0755'

saltymacs_update_script:
  file.managed:
    - name: /usr/local/saltymacs/updateSaltymacs.zsh
    - source: /opt/saltyMacs/salt/saltyStuff/updateSaltymacs.zsh
    - user: root
    - group: wheel
    - mode: '0755'
    - require:
      - file: saltymacs_runtime_dir
