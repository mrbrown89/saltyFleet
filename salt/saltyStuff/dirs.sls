saltymacs_repo_dir:
  file.directory:
    - name: /opt/saltyFleet
    - user: root
    - group: wheel
    - mode: 755

saltymacs_log_file:
  file.touch:
    - name: /var/log/saltyfleet.log
