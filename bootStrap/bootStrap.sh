#!/bin/zsh --no-rcs

set -euo pipefail

userName=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }')
userHome=$(dscl . read /Users/"$userName" NFSHomeDirectory | awk '{print $2}')
brewLocation="/opt/homebrew"

installXcodeTools() {
  echo "Ensuring Xcode Command Line Tools..."

  if xcode-select -p >/dev/null 2>&1; then
    echo "Xcode Command Line Tools already installed."
    return 0
  fi

  echo "Installing Xcode Command Line Tools..."
  xcode-select --install 2>/dev/null || true

  until xcode-select -p >/dev/null 2>&1; do
    sleep 5
  done

  echo "Xcode Command Line Tools installation complete."
}

installHomeBrew() {
  if command -v brew >/dev/null 2>&1; then
    echo "Homebrew already installed."
    eval "$(${brewLocation}/bin/brew shellenv 2>/dev/null || true)"
    return 0
  fi

  if [[ "$(id -u)" -eq 0 ]]; then
    echo "ERROR: Do not run this script as root."
    exit 1
  fi

  sudo -v

  echo "Installing Homebrew for user: ${userName}"

  sudo install -d -o "${userName}" -g wheel -m 0755 "${brewLocation}"
  sudo install -d -o root -g wheel -m 0755 /etc/paths.d
  echo "${brewLocation}/bin" | sudo tee /etc/paths.d/homebrew >/dev/null
  sudo chmod a+r /etc/paths.d/homebrew

  echo "Running Homebrew installer..."
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  eval "$(${brewLocation}/bin/brew shellenv)"
  export PATH="${brewLocation}/bin:${brewLocation}/sbin:${PATH}"

  if ! grep -q "brew shellenv" "${userHome}/.zprofile" 2>/dev/null; then
    {
      echo "# Homebrew"
      echo "eval \"\$(${brewLocation}/bin/brew shellenv)\""
    } >> "${userHome}/.zprofile"
  fi

  brew update
}

userDotFiles() {
  echo "Ensuring dotfiles exist for ${userName}..."

  for file in ".zshrc" ".vimrc"; do
    if [[ ! -f "${userHome}/${file}" ]]; then
      echo "Creating ${userHome}/${file}"
      sudo -u "${userName}" touch "${userHome}/${file}"
    else
      echo "${file} already exists"
    fi

    sudo chown "${userName}":staff "${userHome}/${file}"
    sudo chmod 0644 "${userHome}/${file}"
  done
}

installSalt() {
  echo "Ensuring Salt is installed..."

  eval "$(${brewLocation}/bin/brew shellenv 2>/dev/null || true)"
  export PATH="/usr/local/sbin:/usr/local/bin:${brewLocation}/bin:${brewLocation}/sbin:${PATH}"

  if ! command -v salt-call >/dev/null 2>&1; then
    brew install salt
  else
    echo "Salt already installed."
  fi

  echo "Salt version:"
  salt-call --version
}

runSalt() {
  echo "Running Salt states (masterless)..."

  scriptDir="${0:A:h}"

  # Dynamically find the salt state directory
  saltStatePath="${saltStatePath:-${scriptDir}/../salt}"
  saltStatePath="$(cd "${saltStatePath}" && pwd)"

  if [[ ! -f "${saltStatePath}/top.sls" ]]; then
    echo "FATAL: top.sls not found."
    echo "Expected at: ${saltStatePath}/top.sls"
    exit 1
  fi

  echo "Using Salt state directory: ${saltStatePath}"

  # Dynamically find the pillar directory
  pillarPath="${pillarPath:-${scriptDir}/../pillar}"
  pillarPath="$(cd "${pillarPath}" && pwd)"

  if [[ ! -f "${pillarPath}/top.sls" ]]; then
    echo "FATAL: top.sls not found in pillar directory."
    echo "Expected at: ${pillarPath}/top.sls"
    exit 1
  fi

  echo "Using Salt pillar directory: ${pillarPath}"

  # Run masterless salt-call with dynamic file root and pillar root. Means the repo can be cloned to anywhere.
  sudo salt-call --local state.apply \
    saltenv=base \
    --file-root="${saltStatePath}" \
    --pillar-root="${pillarPath}"
}

main() {

  installXcodeTools
  installHomeBrew
  userDotFiles
  installSalt
  runSalt

  echo "Bootstrap complete. Whoop!"
}

main
