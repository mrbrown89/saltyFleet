{% set user = pillar['user']['primary_user'] %}
{% set home = pillar['user']['home_dir'] %}

# -----------------------------
# Ghostty Config
# -----------------------------

ghostty_config:
  file.managed:
    - name: {{ home }}/Library/Application Support/com.mitchellh.ghostty/config
    - source: salt://ghostty/files/config
    - makedirs: True
    - user: {{ user }}
    - group: staff
    - mode: '0644'
