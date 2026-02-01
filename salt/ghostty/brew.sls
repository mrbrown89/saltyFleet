{% set user = pillar['user']['primary_user'] %}
{% set brew = '/opt/homebrew/bin/brew' %}

ghostty_cask:
  cmd.run:
    - name: {{ brew }} install --cask ghostty
    - runas: {{ user }}
    - unless: {{ brew }} list --cask ghostty
