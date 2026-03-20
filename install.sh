#!/bin/bash
# Enable strict mode for better error handling
# -e: Exit immediately if a command exits with a non-zero status
# -u: Treat unset variables as an error when substituting
# -o pipefail: The return value of a pipeline is the status of the last command to exit with a non-zero status
set -euo pipefail  

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Target directories/files for vim and git configurations
VIM_TARGET_DIR="$HOME/.vim/r-vim-init"
GIT_CONFIG_TARGET="$HOME/.gitconfig"
VIMRC_TARGET="$HOME/.vimrc"

# ==============================================
# Step 1: Clone r-vim-init repository
# ==============================================
# Remove existing .vim directory if it exists (force delete recursively)
if [ -d "$VIM_TARGET_DIR" ]; then
    echo "Removing existing $VIM_TARGET_DIR directory..."
    rm -rf "$VIM_TARGET_DIR"
fi

echo "=== Cloning r-vim-init configuration repository ==="
if ! git clone https://github.com/Rqirus/r-vim-init.git "$VIM_TARGET_DIR"; then
    echo "ERROR: Failed to clone repository! Check network or repository URL." >&2
    exit 1
fi

# ==============================================
# Step 2: Backup existing configuration files
# (Only backup regular files, skip directories)
# ==============================================
echo -e "\n=== Backing up existing configuration files ==="

# Backup .gitconfig with timestamp (avoid overwriting old backups)
if [ -f "$GIT_CONFIG_TARGET" ]; then
    BACKUP_GIT_CONFIG="${GIT_CONFIG_TARGET}_bak_$(date +%Y%m%d_%H%M%S)"
    cp "$GIT_CONFIG_TARGET" "$BACKUP_GIT_CONFIG"
    echo "Backed up $GIT_CONFIG_TARGET to $BACKUP_GIT_CONFIG"
else
    echo "$GIT_CONFIG_TARGET does not exist - no backup needed"
fi

# Backup .vimrc with timestamp
if [ -f "$VIMRC_TARGET" ]; then
    BACKUP_VIMRC="${VIMRC_TARGET}_bak_$(date +%Y%m%d_%H%M%S)"
    cp "$VIMRC_TARGET" "$BACKUP_VIMRC"
    echo "Backed up $VIMRC_TARGET to $BACKUP_VIMRC"
else
    echo "$VIMRC_TARGET does not exist - no backup needed"
fi

# ==============================================
# Step 3: Copy new configuration files
# (Use source files from script's directory)
# ==============================================
echo -e "\n=== Copying new configuration files ==="

# Check if source gitconfig exists
if [ ! -f "$SCRIPT_DIR/gitconfig" ]; then
    echo "ERROR: Source file $SCRIPT_DIR/gitconfig not found!" >&2
    exit 1
fi

# Check if source vimrc exists
if [ ! -f "$SCRIPT_DIR/vimrc" ]; then
    echo "ERROR: Source file $SCRIPT_DIR/vimrc not found!" >&2
    exit 1
fi

cp -f bin/* /usr/local/bin/


# Copy configuration files to target locations
cp "$SCRIPT_DIR/gitconfig" "$GIT_CONFIG_TARGET"
cp "$SCRIPT_DIR/vimrc" "$VIMRC_TARGET"

# ==============================================
# Final confirmation
# ==============================================
echo -e "\n=== Setup completed successfully! All operations finished ==="
exit 0
