#!/bin/sh

set -e -o pipefail

BARE_TEMPLATE_DIR="/srv/git/templates/default"

mkdir -pv $BARE_TEMPLATE_DIR

# Initialize the bare repository
git init --bare $BARE_TEMPLATE_DIR

# Set the restrictive settings in the bare repository
cd $BARE_TEMPLATE_DIR
git config receive.fsckobjects true
git config receive.denynonfastforwards true
git config receive.denydeletes true
git config receive.denycurrentbranch ignore
git config http.receivepack true

# Clean up the non-bare template directory
cd $BARE_TEMPLATE_DIR

echo "Template repository created successfully."
