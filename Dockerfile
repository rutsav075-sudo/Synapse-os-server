FROM n8nio/n8n:latest

USER root

# Copy the custom branding patch script into the container
COPY patch-n8n.cjs /patch-n8n.cjs

# Run the script to patch the n8n UI and remove X-Frame-Options
RUN node /patch-n8n.cjs

# Disable default security headers
ENV N8N_DISABLE_UI_SECURITY=true

# Force n8n to use port 8080 and tell Railway to route traffic there
ENV N8N_PORT=8080
EXPOSE 8080

# Switch back to the safe node user
USER node
