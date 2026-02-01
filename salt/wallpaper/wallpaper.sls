{% set user = pillar['user']['primary_user'] %}

# -----------------------------
# Set the wallpaper
# -----------------------------

set_wallpaper:
  cmd.run:
    - name: "osascript -e 'tell application \"System Events\" to set picture of every desktop to \"/System/Library/Desktop Pictures/Solid Colors/Space Gray Pro.png\"'"
    - runas: {{ user }}
