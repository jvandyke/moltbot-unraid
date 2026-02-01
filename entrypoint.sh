#!/bin/bash
set -e

# Define the location for the persistent token file
# We use the .openclaw directory because that is mapped to Appdata
TOKEN_FILE="/home/node/.openclaw/.generated_token"

# 1. Check if the user provided a token via Unraid/Env Vars
if [ -n "$OPENCLAW_GATEWAY_TOKEN" ]; then
    echo "Starting Moltbot with user-provided Gateway Token."

# 2. If not, check if we have already generated one in the past
elif [ -f "$TOKEN_FILE" ]; then
    export OPENCLAW_GATEWAY_TOKEN=$(cat "$TOKEN_FILE")
    echo "----------------------------------------------------------------"
    echo "MOLTBOT STARTUP: Using previously generated token."
    echo "GATEWAY TOKEN: $OPENCLAW_GATEWAY_TOKEN"
    echo "----------------------------------------------------------------"

# 3. If neither, generate a new one, save it, and print it
else
    echo "No Gateway Token provided. Generating a new secure token..."
    # Generate a random 32-byte hex string
    GENERATED_TOKEN=$(openssl rand -hex 32)
    
    # Save it to the persistent volume so it survives restarts
    echo "$GENERATED_TOKEN" > "$TOKEN_FILE"
    
    export OPENCLAW_GATEWAY_TOKEN="$GENERATED_TOKEN"
    
    echo "----------------------------------------------------------------"
    echo "MOLTBOT STARTUP: A new Gateway Token has been generated."
    echo "Use this token to log in to the Web UI:"
    echo ""
    echo "GATEWAY TOKEN: $OPENCLAW_GATEWAY_TOKEN"
    echo ""
    echo "This token is saved in your Appdata folder for future restarts."
    echo "----------------------------------------------------------------"
fi

# Execute the original command (usually passed from CMD in Dockerfile)
exec "$@"
