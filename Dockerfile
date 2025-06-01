FROM caddy:2

# Install required packages
RUN apk add --no-cache \
    fcgiwrap \
    jq \
    git

# Create necessary directories
RUN mkdir -pv /srv/git/repos \
    /srv/git/scripts \
    /srv/git/templates

# Copy scripts and Caddyfile
COPY server/scripts/ /srv/git/scripts/
COPY Caddyfile /etc/caddy/Caddyfile

# Make scripts executable
RUN chmod +x /srv/git/scripts/*

# Set up environment variables
ENV GIT_DOMAIN=""
ENV ADMIN_EMAIL=""
ENV GIT_SERVER_URL=""
ENV BACKEND_URL=""

# Expose ports
EXPOSE 80 443

# Start fcgiwrap and Caddy
CMD ["sh", "-c", "fcgiwrap -s unix:/var/run/fcgiwrap.socket & caddy run --config /etc/caddy/Caddyfile"] 