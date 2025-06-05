#!/bin/bash

# dotfiles.sh: A simple dotfiles manager to symlink configuration files

set -e

# Default values
DOTFILES_DIR=$(dirname "${BASH_SOURCE[0]}")
TARGET_DIR="$HOME"
DRY_RUN=false
FORCE=false

# Print usage information
usage() {
    echo "Usage: $0 [-d dotfiles_dir] [-t target_dir] [-f] [-n] <command> [package]"
    echo "Commands:"
    echo "  install <package>  Install symlinks for a package"
    echo "  remove <package>   Remove symlinks for a package"
    echo "  list               List available packages"
    echo "Options:"
    echo "  -d <dir>           Set dotfiles directory (default: directory dotfiles.sh is located)"
    echo "  -t <dir>           Set target directory (default: ~)"
    echo "  -f                 Force overwrite existing files"
    echo "  -n                 Dry run (show actions without performing them)"
    exit 1
}

# Check if a package exists
check_package() {
    local package="$1"
    if [ ! -d "$DOTFILES_DIR/$package" ]; then
        echo "Error: Package '$package' not found in $DOTFILES_DIR"
        exit 1
    fi
}

# Create a single symlink
create_symlink() {
    local src="$1"
    local dest="$2"
    
    if [ -e "$dest" ] && [ "$FORCE" != "true" ]; then
        echo "Warning: $dest already exists. Use -f to overwrite."
        return 1
    fi
    
    if [ "$DRY_RUN" = "true" ]; then
        echo "Would create symlink: $dest -> $src"
        return 0
    fi
    
    mkdir -p "$(dirname "$dest")"
    ln -sf "$src" "$dest" && echo "Created symlink: $dest -> $src"
}

# Remove a single symlink
remove_symlink() {
    local dest="$1"
    
    if [ -L "$dest" ]; then
        if [ "$DRY_RUN" = "true" ]; then
            echo "Would remove symlink: $dest"
            return 0
        fi
        rm "$dest" && echo "Removed symlink: $dest"
    fi
}

# Install a package
install_package() {
    local package="$1"
    check_package "$package"
    
    find "$DOTFILES_DIR/$package" -type f | while read -r src; do
        # Calculate relative path and destination
        local rel_path="${src#$DOTFILES_DIR/$package/}"
        local dest="$TARGET_DIR/$rel_path"
        
        create_symlink "$src" "$dest"
    done
}

# Remove a package
remove_package() {
    local package="$1"
    check_package "$package"
    
    find "$DOTFILES_DIR/$package" -type f | while read -r src; do
        local rel_path="${src#$DOTFILES_DIR/$package/}"
        local dest="$TARGET_DIR/$rel_path"
        
        remove_symlink "$dest"
    done
}

# List available packages
list_packages() {
    ls -1 "$DOTFILES_DIR" | while read -r package; do
        if [ -d "$DOTFILES_DIR/$package" ]; then
            echo "$package"
        fi
    done
}

# Parse command line options
while getopts "d:t:fn" opt; do
    case $opt in
        d) DOTFILES_DIR="$OPTARG" ;;
        t) TARGET_DIR="$OPTARG" ;;
        f) FORCE=true ;;
        n) DRY_RUN=true ;;
        *) usage ;;
    esac
done
shift $((OPTIND-1))

# Check for command
if [ $# -eq 0 ]; then
    usage
fi

COMMAND="$1"
shift

# Expand ~ in paths
DOTFILES_DIR="${DOTFILES_DIR/#\~/$HOME}"
TARGET_DIR="${TARGET_DIR/#\~/$HOME}"

# Ensure dotfiles directory exists
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Error: Dotfiles directory '$DOTFILES_DIR' does not exist"
    exit 1
fi

# Process commands
case "$COMMAND" in
    install)
        [ $# -ne 1 ] && usage
        install_package "$1"
        ;;
    remove)
        [ $# -ne 1 ] && usage
        remove_package "$1"
        ;;
    list)
        [ $# -ne 0 ] && usage
        list_packages
        ;;
    *)
        usage
        ;;
esac