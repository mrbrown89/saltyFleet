{% set user = pillar['user']['primary_user'] %}

# -----------------------------
# vim enviroment
# -----------------------------

vimrc_file:
  file.touch:
    - name: /Users/{{ user }}/.vimrc
    - user: {{ user }}
    - group: staff
    - mode: 644

vimrc:
  file.managed:
    - name: /Users/{{ user }}/.vimrc
    - user: {{ user }}
    - group: staff
    - mode: '0644'
    - contents: |
        set number
        syntax on
