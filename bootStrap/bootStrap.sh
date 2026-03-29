#!/bin/zsh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

install_fleetctl() {
  if [ ! -f "$HOME/.fleetctl/fleetctl" ]; then
    echo "Installing fleetctl..."
    curl -sSL https://fleetdm.com/resources/install-fleetctl.sh | bash
  else
    echo "fleetctl already installed"
  fi
}

start_fleet() {
  echo "Starting Fleet preview..."
  "$HOME/.fleetctl/fleetctl" preview
}

fleet_config() {

 ~/.fleetctl/fleetctl config set --file ~/Code/saltyFleet/fleet/osqueryOptions.json
 ~/.fleetctl/fleetctl apply -f ~/Code/saltyFleet/fleet/queries.yml

}

main() {
  install_fleetctl
  start_fleet
  start_munki

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
