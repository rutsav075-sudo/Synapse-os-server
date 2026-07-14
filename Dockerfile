FROM n8nio/n8n:latest

# 1. Ensure Railway can connect to n8n by listening on all interfaces
ENV N8N_LISTEN_ADDRESS=0.0.0.0

# 2. Force Railway to route to exactly this port
ENV N8N_PORT=8080
EXPOSE 8080

# 3. Disable n8n's basic security headers
ENV N8N_DISABLE_UI_SECURITY=true

USER root

# 4. Copy and run your custom Synapse branding patch
COPY patch-n8n.cjs /patch-n8n.cjs
RUN node /patch-n8n.cjs

# 5. Surgically remove the SAMEORIGIN block that causes the iframe error
RUN sed -i "s/{ action: 'sameorigin' }/false/g" /usr/local/lib/node_modules/n8n/dist/server.js || true

USER node
# We intentionally do NOT include a CMD or ENTRYPOINT here.
# This forces n8n to start using its official, native startup sequence.
