#!/bin/bash

set -e -o pipefail

# Create new repository from template
# Usage: init_repo.sh --id <REPO NAME> --template <TEMPLATE REPO>

# Load the secure token from AWS Secrets Manager
SECURE_TOKEN=$(aws secretsmanager get-secret-value --secret-id secure-token --query SecretString --output text)

function parse_params {
    local input=""
    read -r input
    echo "$input" | jq -r '.'
}

function cleanup {
    rm -rf "$tmp_dir"
}

function create_repo {
    local repo_name="$1"
    local template_repo="$2"
    local repo_dir="/srv/git/repos/$repo_name"
    local template_dir="/srv/git/templates/$template_repo"
    local default_template_dir="/srv/git/templates/default"
    tmp_dir="$(mktemp -d -p /tmp git-clone-XXXXXX)"

    trap cleanup EXIT

    if [ -d "$repo_dir" ]; then
        echo "Status: 400 Bad Request"
        echo "Content-Type: application/json"
        echo ""
        echo "{\"error\": \"Repository already exists: $repo_name\"}"
        exit 1
    fi

    if [ ! -d "$template_dir" ]; then
        echo "Status: 400 Bad Request"
        echo "Content-Type: application/json"
        echo ""
        echo "{\"error\": \"Template repository does not exist: $template_repo\"}"
        exit 1
    fi

    echo "Creating repository: $repo_name"
    mkdir -pv "$repo_dir"
    git init --bare --template="$default_template_dir" "$repo_dir" >/dev/null 2>&1 || { echo "Failed to create repository"; exit 1; }
    git clone "$repo_dir" "$tmp_dir"
    cp -r "$template_dir"/. "$tmp_dir"
    cd "$tmp_dir"
    git add .
    git config user.name "dotcodeschool-bot" && git config user.email "hello@dotcodeschool.com"
    git commit -m "init [skip ci]"
    git push origin master
    cd
}

if [[ "$REQUEST_METHOD" != "POST" ]]; then
    echo "Status: 405 Method Not Allowed"
    echo "Content-Type: application/json"
    echo ""
    echo "{\"error\": \"Method not allowed\"}"
    exit 1
fi

AUTH_TOKEN=$(echo "$HTTP_AUTHORIZATION" | cut -d' ' -f2)

if [ "$AUTH_TOKEN" != "$SECURE_TOKEN" ]; then
    echo "Status: 403 Forbidden"
    echo "Content-Type: application/json"
    echo ""
    echo "{\"error\": \"Unauthorized\"}"
    exit 1
fi

PARAMS=$(parse_params)
REPO_NAME=$(echo "$PARAMS" | jq -r '.repo_name')
TEMPLATE_REPO=$(echo "$PARAMS" | jq -r '.template_repo')

if [ -z "$REPO_NAME" ]; then
    echo "Status: 400 Bad Request"
    echo "Content-Type: application/json"
    echo ""
    echo "{\"error\": \"Repository name is required\"}"
    exit 1
fi

create_repo "$REPO_NAME" "${TEMPLATE_REPO:-default}"

echo "Status: 201 Created"
echo "Content-Type: application/json"
echo ""
echo "{\"message\": \"Repository $repo_name created successfully\"}"
