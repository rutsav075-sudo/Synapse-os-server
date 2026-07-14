FROM n8nio/n8n:latest

# Make sure n8n listens on all network interfaces so Railway can reach it
ENV N8N_LISTEN_ADDRESS=0.0.0.0

# Tell Railway to use port 8080, and tell n8n to listen on port 8080
ENV N8N_PORT=8080
EXPOSE 8080

# Disable n8n's default security protections
ENV N8N_DISABLE_UI_SECURITY=true

USER root

# Copy the custom branding patch script into the container
COPY patch-n8n.cjs /patch-n8n.cjs

# Run the script to patch the n8n UI
RUN node /patch-n8n.cjs

# Surgically remove the X-Frame-Options block from the backend code safely
RUN sed -i "s/{ action: 'sameorigin' }/false/g" /usr/local/lib/node_modules/n8n/dist/server.js || true

# Switch back to the safe node user
USER node

# We intentionally do NOT override CMD or ENTRYPOINT so n8n starts natively
