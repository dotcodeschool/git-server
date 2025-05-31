# Dot Code School Git Server

A custom Git server implementation for Dot Code School, providing repository management and webhooks.

## Prerequisites

- Ubuntu/Debian-based system
- Root or sudo access
- Domain name configured with DNS A record pointing to server IP

## Installation

### 1. Install Required Packages

```bash
# Install fcgiwrap for Git HTTP operations
sudo apt-get install fcgiwrap

# Install jq for JSON parsing
sudo apt-get install jq
```

### 2. Configure fcgiwrap

```bash
# Start and enable fcgiwrap service
sudo systemctl start fcgiwrap
sudo systemctl enable fcgiwrap
```

### 3. Set Up Directory Structure

```bash
# Create required directories
sudo mkdir -pv /srv/git/{repos,scripts,templates}

# Copy scripts to git server
sudo cp -r scripts /srv/git/

# Make scripts executable
sudo chmod +x /srv/git/scripts/*
```

### 4. Install and Configure Caddy

1. Install Caddy server
2. Create a Caddy environment file at `/etc/caddy/caddy.env`:

```bash
# Git server configuration
GIT_DOMAIN=git.yourdomain.com
ADMIN_EMAIL=admin@yourdomain.com
GIT_SERVER_URL=https://git.yourdomain.com
BACKEND_URL=https://backend.yourdomain.com
```

3. Update `/etc/caddy/Caddyfile` with your configuration
4. Enable port binding for Caddy:

```bash
sudo setcap cap_net_bind_service=+ep /usr/bin/caddy
```

### 5. Set Up Permissions

```bash
# Update permissions for repos directory
sudo chown -R www-data:caddy /srv/git/repos
sudo chmod -R 775 /srv/git/repos
```

## Configuration

### Template Repository

1. Create a default template repository:

```bash
/srv/git/scripts/create_git_template.sh
```

2. (Optional) Add custom hooks to `/srv/git/templates/default/hooks/`

## Usage

### Creating a New Repository

Send a POST request to create a new repository:

```bash
curl -H "Content-Type: application/json" \
     -H "Authorization: Bearer <your-auth-token>" \
     -d '{
           "repo_name": "<your-repo>",
           "template_repo": "default"
         }' \
     https://git.yourdomain.com/api/v0/create_repository
```

## Security Notes

1. Keep your authentication tokens secure
2. Regularly update system packages and Caddy
3. Monitor server logs for suspicious activity

## Troubleshooting

1. Check fcgiwrap status:

```bash
sudo systemctl status fcgiwrap
```

2. Check Caddy logs:

```bash
sudo journalctl -u caddy
```

3. Verify repository permissions:

```bash
ls -la /srv/git/repos
```

## License

This project is licensed under the [WTFPL](LICENSE) - Do What The Fuck You Want To Public License.
