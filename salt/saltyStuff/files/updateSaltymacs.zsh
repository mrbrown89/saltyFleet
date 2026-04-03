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
