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

start_minio() {
  echo "Starting MinIO container for packages..."

  # Check if container exists
  if ! docker ps -a --format '{{.Names}}' | grep -q "^minio\$"; then
    echo "Creating MinIO container..."
    docker run -d \
      --name minio \
      -p 9000:9000 \
      -p 8080:9001 \
      -e MINIO_ROOT_USER=minioadmin \
      -e MINIO_ROOT_PASSWORD=minioadmin \
      -v minio_data:/data \
      minio/minio server /data --console-address ":9001"
    sleep 5
  else
    echo "MinIO container already exists. Starting if stopped..."
    docker start minio || true
    sleep 5
  fi

  # Ensure mc (MinIO client) is available
  if ! command -v mc >/dev/null 2>&1; then
    echo "Installing MinIO client (mc)..."
    curl -sSL https://dl.min.io/client/mc/release/linux-amd64/mc -o /usr/local/bin/mc
    chmod +x /usr/local/bin/mc
  fi

  # Configure alias and create packages bucket
  mc alias set local http://localhost:9000 minioadmin minioadmin
  mc mb -p local/packages || echo "Bucket 'packages' already exists"

  echo "MinIO setup complete. Web UI: http://localhost:8080"
}

fleet_config() {

 ~/.fleetctl/fleetctl config set --file ~/Code/saltyFleet/fleet/osqueryOptions.json
 ~/.fleetctl/fleetctl apply -f ~/Code/saltyFleet/fleet/queries.yml

}

main() {
  install_fleetctl
  start_fleet
  start_minio

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
