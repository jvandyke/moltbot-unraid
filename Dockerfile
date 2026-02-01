# Start from the official Node image
FROM node:22-bookworm

# Install necessary system tools
RUN apt-get update && apt-get install -y openssl && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy dependency definitions
# These files exist because the GitHub Action checked out the OpenClaw code
COPY package.json pnpm-lock.yaml ./
COPY pnpm-workspace.yaml .npmrc ./ 
# (Note: OpenClaw uses pnpm workspaces, so we might need these too)

# Install dependencies
# Enable corepack to use the pnpm version specified in package.json
RUN corepack enable && pnpm install --frozen-lockfile

# Copy the rest of the application code (Source + Entrypoint)
COPY . .

# Build the application
RUN pnpm build

# --- ENTRYPOINT SETUP ---
RUN chmod +x entrypoint.sh

# Define the entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]

# Default command
CMD ["node", "dist/index.js"]
