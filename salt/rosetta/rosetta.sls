install_rosetta:
  cmd.run:
    - name: |
        if ! /usr/bin/pgrep oahd >/dev/null 2>&1; then
          echo "Installing Rosetta..."
          /usr/sbin/softwareupdate --install-rosetta --agree-to-license
        else
          echo "Rosetta already installed."
        fi
    - runas: root
    - onlyif: test "$(arch)" = "arm64"
