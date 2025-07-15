#!/bin/bash
set -e

# Clone the repository if .git doesn't exist and required variables are set
if [[ ! -d .git && -n "${USERNAME}" && -n "${GIT_ADDRESS}" ]]; then
    REPO_NAME=$(basename -s .git "${GIT_ADDRESS}")
    CLONE_DIR="${USERNAME}_${REPO_NAME}"

    rm -rf "${CLONE_DIR}"

    if [[ -n "${ACCESS_TOKEN}" ]]; then
        # Clone with access token
        git clone -b "${BRANCH}" "https://${USERNAME}:${ACCESS_TOKEN}@${GIT_ADDRESS#https://}" "${CLONE_DIR}"
    else
        # Clone without access token
        git clone -b "${BRANCH}" "https://${USERNAME}@${GIT_ADDRESS#https://}" "${CLONE_DIR}"
    fi

    # Move all files (including hidden ones) from clone dir to current directory
    shopt -s dotglob nullglob
    mv "${CLONE_DIR}"/* "${CLONE_DIR}"/.* ./ 2>/dev/null || true
    shopt -u dotglob nullglob

    rm -rf "${CLONE_DIR}"
fi

# Pull latest changes if AUTO_UPDATE enabled and .git exists
if [[ "${AUTO_UPDATE}" == "1" && -d .git ]]; then
    git pull --no-rebase
fi

# Uninstall specified npm packages if any
if [[ -n "${UNNODE_PACKAGES}" ]]; then
    $(which npm) uninstall ${UNNODE_PACKAGES}
fi

# Install npm packages if package.json exists
if [[ -f package.json ]]; then
    $(which npm) install
fi

# Install additional npm packages if specified
if [[ -n "${NODE_PACKAGES}" ]]; then
    $(which npm) install ${NODE_PACKAGES}
fi

# Execute custom command if specified
if [[ -n "${COMMAND}" ]]; then
    eval "${COMMAND}"
fi
