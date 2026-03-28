install_xcode_clt:
  cmd.run:
    - name: |
        set -e

        PLACEHOLDER=/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
        trap 'rm -f "$PLACEHOLDER"' EXIT

        touch "$PLACEHOLDER"

        CLT_PACKAGE=$(
          softwareupdate -l 2>/dev/null |
          awk -F'*' '/\*.*Command Line Tools/ {gsub(/^ +|^Label: /, "", $2); print $2; exit}'
        )

        if [ -z "$CLT_PACKAGE" ]; then
          echo "No Command Line Tools package found"
          exit 1
        fi

        softwareupdate -i "$CLT_PACKAGE" --verbose

        if [ -d /Library/Developer/CommandLineTools ]; then
          xcode-select --switch /Library/Developer/CommandLineTools
        fi
    - unless: test -d /Library/Developer/CommandLineTools/usr/bin
    - shell: /bin/zsh
