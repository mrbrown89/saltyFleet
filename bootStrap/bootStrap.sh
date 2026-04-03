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

start_jenkins() {
  echo "Starting Jenkins container"
  docker compose -f "$SCRIPT_DIR/../ci/jenkins/docker-compose.yml" up -d
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
  install_fleetctl
  start_fleet
  start_bucket
  start_jenkins
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
