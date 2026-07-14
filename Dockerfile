FROM n8nio/n8n:latest

USER root

# Copy the custom branding patch script into the container
COPY patch-n8n.cjs /patch-n8n.cjs

# Run the script to patch the n8n UI and remove X-Frame-Options
RUN node /patch-n8n.cjs

# Disable default security headers
ENV N8N_DISABLE_UI_SECURITY=true

# Switch back to the safe node user
USER node

# Reset entrypoint so we can use a shell command to map the Railway port
ENTRYPOINT []

# Map the dynamic Railway $PORT to n8n, then start it normally
CMD export N8N_PORT=${PORT:-5678} && exec tini -- /docker-entrypoint.sh n8n
