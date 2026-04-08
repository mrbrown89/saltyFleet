#!/bin/zsh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

install_xcode_tools() {
  echo ">>> Ensuring Xcode Command Line Tools (if needed)..."

  if ! xcode-select -p >/dev/null 2>&1; then
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    softwareupdate -l >/dev/null 2>&1 || true

    CLT_LABEL="$(
      softwareupdate -l 2>&1 |
        awk -F'*' '/Command Line Tools for Xcode/{print $2}' |
        sed 's/^ Label: //;s/^ *//;q' || true
    )"

    if [[ -n "${CLT_LABEL}" ]]; then
      sudo softwareupdate -i "${CLT_LABEL}" --verbose
      sudo xcode-select --switch /Library/Developer/CommandLineTools
    fi

    rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  else
    echo ">>> Command Line Tools already installed."
  fi
}

install_fleetctl() {
  if [ ! -f "$HOME/.fleetctl/fleetctl" ]; then
    echo "Installing fleetctl..."
    curl -sSL https://fleetdm.com/resources/install-fleetctl.sh | bash
  else
    echo "fleetctl already installed"
  fi
}

start_fleet() {
  echo "Starting Fleet preview"
  "$HOME/.fleetctl/fleetctl" preview
}

start_bucket() {
  echo "Starting http bucket container"
  docker compose -f "$SCRIPT_DIR/../bucket/docker-compose.yml" up -d
}

fleet_login() {
  "$HOME/.fleetctl/fleetctl" login --email "admin@example.com" --password "preview1337#"
}

fleet_config() {

  local FLEETCTL="$HOME/.fleetctl/fleetctl"
  local FLEET_DIR="$SCRIPT_DIR/../fleet"

  echo "Applying Fleet configuration from $FLEET_DIR..."

  for file in "$FLEET_DIR"/*.yml; do
    echo "Applying $file"
    "$FLEETCTL" apply -f "$file"
  done

}

main() {
  install_xcode_tools
  install_fleetctl
  start_fleet
  start_bucket
  fleet_login
  fleet_config

  echo ""
  echo "Bootstrap complete!"
  echo ""
  echo "Next steps:"
  echo "1. Open Fleet UI: http://localhost:1337/previewlogin"
  echo "2. Go to Hosts → Add Host → macOS"
  echo "3. cd into .fleetctl and paste the command from fleet"
  echo "4. Place it in: /saltyFleet/ci/packages/"
}

main
