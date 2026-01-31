{% set user = pillar['user']['primary_user'] %}

# -----------------------------
# vim enviroment
# -----------------------------

vimrc_file:
  file.managed:
    - name: /Users/{{ user }}/.vimrc
    - contents: ""
    - mode: '0644'
    - user: {{ user }}
    - group: staff
    
vimrc:
  file.managed:
    - name: /Users/{{ user }}/.vimrc
    - user: {{ user }}
    - group: staff
    - mode: '0644'
    - contents: |
        set number
        syntax on
