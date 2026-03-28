terminal_secure_keyboard:
  macdefaults.write:
    - name: SecureKeyboardEntry
    - domain: /Library/Preferences/com.apple.Terminal
    - value: true
    - vtype: bool
