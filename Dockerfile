FROM n8nio/n8n:latest

# Basic configuration
ENV N8N_LISTEN_ADDRESS=0.0.0.0
ENV N8N_DISABLE_UI_SECURITY=true

USER root

# Copy and run the UI branding patch (logo, hiding menus)
COPY patch-n8n.cjs /patch-n8n.cjs
RUN node /patch-n8n.cjs

USER node
# n8n starts perfectly natively, and Nginx will handle the security headers.
