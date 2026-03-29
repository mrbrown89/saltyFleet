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
  echo "Starting Fleet preview"
  "$HOME/.fleetctl/fleetctl" preview
}

start_bucket() {
  echo "Starting http bucket container"
  docker compose -f "$SCRIPT_DIR/../bucket/docker-compose.yml" up -d
}

fleet_config() {

"$HOME/.fleetctl/fleetctl" config set --file "$SCRIPT_DIR/../fleet/osqueryOptions.json"
"$HOME/.fleetctl/fleetctl" apply -f "$SCRIPT_DIR/../fleet/queries.yml"

}

main() {
  install_fleetctl
  start_fleet
  start_bucket

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
