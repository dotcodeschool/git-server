#!/bin/bash

set -e -o pipefail

# Step 1: Create the template repository
TEMPLATE_DIR="/tmp/git_template"
BARE_TEMPLATE_DIR="/srv/git/templates/default"

# Initialize a non-bare repository for the template
mkdir -pv $TEMPLATE_DIR
cd $TEMPLATE_DIR
git init
git config user.name "dotcodeschool-bot" && git config user.email "hello@dotcodeschool.com"
echo "Initial commit" > README.md
git add README.md
git commit -m "init [skip ci]"

# Convert to a bare repository
git clone --bare . $BARE_TEMPLATE_DIR

# Set the restrictive settings in the bare repository
cd $BARE_TEMPLATE_DIR
git config receive.fsckobjects true
git config receive.denynonfastforwards true
git config receive.denydeletes true
git config receive.denycurrentbranch ignore
git config http.receivepack true

# Clean up the non-bare template directory
cd $BARE_TEMPLATE_DIR
rm -rf $TEMPLATE_DIR

echo "Template repository created successfully."
