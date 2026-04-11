# -----------------------------
# Manage /etc/sudoers.d/mscp
# -----------------------------

sudoers_mscp_managed:
  file.managed:
    - name: /etc/sudoers.d/mscp
    - user: root
    - group: wheel
    - mode: '0644'
    - contents: |
        Defaults log_allowed
        Defaults timestamp_timeout=0
    - check_cmd: /usr/sbin/visudo -cf %s
