FROM n8nio/n8n:latest

USER root

# Copy the custom branding patch script into the container
COPY patch-n8n.cjs /patch-n8n.cjs

# Run the script to patch the n8n UI and remove X-Frame-Options
RUN node /patch-n8n.cjs

# Disable default security headers
ENV N8N_DISABLE_UI_SECURITY=true

# Copy the start script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Switch back to the safe node user
USER node

# Override the entrypoint to map the dynamic Railway PORT
ENTRYPOINT ["/start.sh"]
