#!/bin/sh
# Railway provides the $PORT environment variable dynamically.
# n8n requires the $N8N_PORT environment variable.
# We map it here right before n8n starts to guarantee it binds to the correct port.
export N8N_PORT=${PORT:-5678}

# Execute the original n8n entrypoint
exec tini -- /docker-entrypoint.sh n8n
