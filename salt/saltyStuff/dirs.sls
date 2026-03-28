saltymacs_repo_dir:
  file.directory:
    - name: /opt/salting-macOS
    - user: root
    - group: wheel
    - mode: 755

saltymacs_log_file:
  file.touch:
    - name: /var/log/saltymacs.log
