{% set user = pillar['user']['primary_user'] %}

# -----------------------------
# Set menu clock
# -----------------------------

show_ampm:
  macdefaults.write:
    - name: ShowAMPM
    - domain: com.apple.menuextra.clock
    - value: true
    - user: {{ user }}
    - vtype: bool

show_date:
  macdefaults.write:
    - name: ShowDate
    - domain: com.apple.menuextra.clock
    - value: 0
    - user: {{ user }}
    - vtype: bool

show_week_day:
  macdefaults.write:
    - name: ShowDayofWeek
    - domain: com.apple.menuextra.clock
    - value: true
    - user: {{ user }}
    - vtype: bool

time_announcements_enabled:
  macdefaults.write:
    - name: TimeAnnouncementsEnabled
    - domain: com.apple.menuextra.clock
    - value: false
    - user: {{ user }}
    - vtype: bool

restart_clock:
  cmd.run:
    - name: killall SystemUIServer
    - runas: {{ user }}
    - require:
      - macdefaults: show_ampm
      - macdefaults: show_date
      - macdefaults: show_week_day
      - macdefaults: time_announcements_enabled
