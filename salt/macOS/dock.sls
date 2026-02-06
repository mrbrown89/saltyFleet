{% set user = pillar['user']['primary_user'] %}

# -----------------------------
# Dock Preferences (idempotent)
# -----------------------------

# Autohide
dock_autohide:
  macdefaults.write:
    - name: autohide
    - domain: com.apple.dock
    - value: False
    - user: {{ user }}
    - vtype: bool

# Magnification
dock_magnification:
  macdefaults.write:
    - name: magnification
    - domain: com.apple.dock
    - value: True
    - user: {{ user }}
    - vtype: bool

# Large size for magnified icons
dock_largesize:
  macdefaults.write:
    - name: largesize
    - domain: com.apple.dock
    - value: 128
    - user: {{ user }}
    - vtype: int

# Standard tile size
dock_tilesize:
  macdefaults.write:
    - name: tilesize
    - domain: com.apple.dock
    - value: 49
    - user: {{ user }}
    - vtype: int

# Show recents
dock_show_recents:
  macdefaults.write:
    - name: show-recents
    - domain: com.apple.dock
    - value: False
    - user: {{ user }}
    - vtype: bool

# Hot corner bottom-right modifier
dock_wvous_br_modifier:
  macdefaults.write:
    - name: wvous-br-modifier
    - domain: com.apple.dock
    - value: 0
    - user: {{ user }}
    - vtype: int

# Restart Dock if any settings changed
restart_dock:
  cmd.run:
    - name: killall Dock
    - watch:
      - macdefaults: dock_autohide
      - macdefaults: dock_magnification
      - macdefaults: dock_largesize
      - macdefaults: dock_tilesize
      - macdefaults: dock_show_recents
      - macdefaults: dock_wvous_br_modifier
