{% set user = pillar['user']['primary_user'] %}

# -----------------------------
# Set menu clock
# -----------------------------

show_am/pm:
  macdefaults.write:
    - name: ShowAMPM
    - domain: com.apple.menuextra.clock.plist
    - value: true
    - user: {{ user }}
    - vtype: bool

show_date:
  macdefaults.write:
    - name: ShowDate
    - domain: com.apple.menuextra.clock.plist
    - value: 0
    - user: {{ user }}
    - vtype: int

show_week_day:
  macdefaults.write:
    - name: ShowDayofWeek
    - domain: com.apple.menuextra.clock.plist
    - value: true
    - user: {{ user }}
    - vtype: bool

time_announcements_enabled:
  macdefaults.write:
    - name: TimeAnnouncementsEnabled
    - domain: com.apple.menuextra.clock.plist
    - value: false
    - user: {{ user }}
    - vtype: bool
