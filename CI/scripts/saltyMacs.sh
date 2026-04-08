#!/bin/zsh

PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin

##############################################################################
# Variables
##############################################################################

repoURL="https://github.com/mrbrown89/saltyFleet.git"
repoDir="/opt/saltyFleet"
branch="main"

saltyDir="/usr/local/saltymacs"
updateScript="${saltyDir}/updateSaltymacs.zsh"

plistPath="/Library/LaunchDaemons/com.saltyfleet.saltymacs.plist"
logFile="/var/log/saltymacs.log"

saltConfDir="/etc/salt/minion.d"
saltConfFile="${saltConfDir}/saltymacs.conf"

##############################################################################
# Functions
##############################################################################

logMessage() {
    echo "$(date '+%Y-%m-%d %H:%M:%S')  $1"
}

installXcodeTools() {
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

createDirectories() {
    logMessage "Creating directories"
    mkdir -p "${saltyDir}" "${saltConfDir}" "${repoDir}"
    chown root:wheel "${saltyDir}" "${saltConfDir}"
    chmod 755 "${saltyDir}" "${saltConfDir}"
}

writeSaltConfig() {
    logMessage "Writing Salt config"

    tee "${saltConfFile}" > /dev/null <<EOF
file_client: local

file_roots:
  base:
    - /opt/saltyFleet/salt

pillar_roots:
  base:
    - /opt/saltyFleet/pillar

grains_dirs:
  - /opt/saltyFleet/salt/_grains

module_dirs:
  - /opt/saltyFleet/salt/_modules
EOF

    chown root:wheel "${saltConfFile}"
    chmod 644 "${saltConfFile}"
}

writeUpdateScript() {
    logMessage "Writing update script"

    tee "${updateScript}" > /dev/null <<'EOF'
#!/bin/zsh

PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin

##############################################################################
# Variables
##############################################################################

repoURL="https://github.com/mrbrown89/saltyFleet.git"
repoDir="/opt/saltyFleet"
branch="main"

logFile="/var/log/saltymacs.log"
lockDir="/var/run/saltymacs.lock"

##############################################################################
# Functions
##############################################################################

logMessage() {
    echo "$(date '+%Y-%m-%d %H:%M:%S')  $1"
}

startLogging() {
    exec >> "${logFile}" 2>&1
    logMessage "===== saltyMacs run started ====="
}

acquireLock() {
    if ! mkdir "${lockDir}" 2>/dev/null; then
        logMessage "Run already in progress, exiting"
        exit 0
    fi
    logMessage "Lock acquired"
}

cleanup() {
    rm -rf "${lockDir}" 2>/dev/null
    logMessage "Lock released"
    logMessage "===== saltyMacs run finished ====="
}

cloneOrUpdateRepo() {
    if [[ -d "${repoDir}/.git" ]]; then
        logMessage "Updating repo"
        git -C "${repoDir}" fetch origin || exit 1
        git -C "${repoDir}" reset --hard "origin/${branch}" || exit 1
        git -C "${repoDir}" clean -fd || exit 1
    else
        logMessage "Cloning repo"
        git clone --branch "${branch}" "${repoURL}" "${repoDir}" || exit 1
    fi
}

runSaltCall() {
    saltCall="/opt/salt/salt-call"

    if [[ ! -x "${saltCall}" ]]; then
        logMessage "ERROR: salt-call not found at ${saltCall}"
        exit 1
    fi

    logMessage "Using salt-call at ${saltCall}"

    logMessage "Syncing Salt extensions"
    "${saltCall}" --local saltutil.sync_grains
    "${saltCall}" --local saltutil.sync_modules

    logMessage "Refreshing grains"
    "${saltCall}" --local saltutil.refresh_grains

    logMessage "Running salt-call"
    "${saltCall}" --local state.apply
    result=$?

    # ----------------------------
    # WRITE state.json FOR FLEET
    # ----------------------------
    commit="$(cd /opt/saltyFleet && git rev-parse HEAD 2>/dev/null)"
    runStatus="success"
    [[ "${result}" -ne 0 ]] && runStatus="failed"

    printf '%s\n' "{\"repo_commit\":\"${commit}\",\"last_run\":\"$(date -u +%FT%TZ)\",\"salt_status\":\"${runStatus}\"}" > /usr/local/saltymacs/state.json

    return "${result}"
}

main() {
    startLogging
    acquireLock

    trap 'cleanup; exit 1' INT TERM HUP

    cloneOrUpdateRepo
    runSaltCall

    cleanup
}

main
EOF

    chown root:wheel "${updateScript}"
    chmod 755 "${updateScript}"
}

writeLaunchDaemon() {
    logMessage "Writing LaunchDaemon"

    tee "${plistPath}" > /dev/null <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.saltyfleet.saltymacs</string>

    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/saltymacs/updateSaltymacs.zsh</string>
    </array>

    <key>RunAtLoad</key>
    <true/>

    <key>StartInterval</key>
    <integer>600</integer>

    <key>StandardOutPath</key>
    <string>/var/log/saltymacs.log</string>

    <key>StandardErrorPath</key>
    <string>/var/log/saltymacs.log</string>
</dict>
</plist>
EOF

    chown root:wheel "${plistPath}"
    chmod 644 "${plistPath}"
}

loadLaunchDaemon() {
    logMessage "Loading LaunchDaemon"

    if /bin/launchctl print system/com.saltyfleet.saltymacs >/dev/null 2>&1; then
        logMessage "Reloading existing daemon"
        /bin/launchctl bootout system "${plistPath}" >/dev/null 2>&1
    fi

    /bin/launchctl bootstrap system "${plistPath}" || exit 1
}

##############################################################################
# Main
##############################################################################

main() {
    exec >> "${logFile}" 2>&1

    logMessage "===== saltyMacs bootstrap started ====="
    installXcodeTools
    createDirectories
    writeSaltConfig
    writeUpdateScript
    writeLaunchDaemon
    loadLaunchDaemon

    logMessage "===== saltyMacs bootstrap finished ====="
}

main
