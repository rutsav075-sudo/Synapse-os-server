FROM n8nio/n8n:latest

USER root

# Copy the custom branding patch script into the container
COPY patch-n8n.cjs /patch-n8n.cjs

# Run the script to patch the n8n UI inside the container before it starts
RUN node /patch-n8n.cjs

# Switch back to the safe node user
USER node
