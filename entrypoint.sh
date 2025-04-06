#!/bin/sh -l

# Arguments:
# $1 = Host
# $2 = Port
# $3 = Username
# $4 = Key filename (e.g., id_rsa)
# $5 = Private key contents
# $6 = SSH command to run
# $7 = CF_ACCESS_CLIENT_ID
# $8 = CF_ACCESS_CLIENT_SECRET

set -e

echo "⚙️ Setting up environment..."

# Save CF Access token environment variables
export CF_ACCESS_CLIENT_ID="$7"
export CF_ACCESS_CLIENT_SECRET="$8"

# Print token vars for debugging (comment out if sensitive)
echo "Using CF_ACCESS_CLIENT_ID=${CF_ACCESS_CLIENT_ID:0:6}******"
echo "Using CF_ACCESS_CLIENT_SECRET=${CF_ACCESS_CLIENT_SECRET:0:6}******"

# Create SSH config
mkdir -p /root/.ssh
touch /root/.ssh/config

# Add SSH host to config
echo "Host $1" >> /root/.ssh/config
echo "    HostName $1" >> /root/.ssh/config
echo "    User $3" >> /root/.ssh/config
echo "    IdentityFile /root/.ssh/$4" >> /root/.ssh/config

# 💡 Inline ENV vars directly to ensure ProxyCommand sees them
echo "    ProxyCommand env CF_ACCESS_CLIENT_ID=$7 CF_ACCESS_CLIENT_SECRET=$8 cloudflared access ssh --hostname %h" >> /root/.ssh/config

# Save private key
echo "$5" > /root/.ssh/$4
chmod 600 /root/.ssh/$4

# Add host to known_hosts (optional if using ProxyCommand)
ssh-keyscan "$1" >> /root/.ssh/known_hosts 2>/dev/null || true

# Debug SSH config
echo "📝 SSH Config:"
cat /root/.ssh/config

# Debug ENV (optional, remove if security-sensitive)
echo "🔐 Cloudflared ENV:"
env | grep CF_ACCESS || echo "⚠️ CF_ACCESS env vars missing"

curl -i "$1" \
      -H "CF-Access-Client-Id: $CF_ACCESS_CLIENT_ID" \
      -H "CF-Access-Client-Secret: $CF_ACCESS_CLIENT_SECRET"

# Execute SSH
echo "🚀 Executing SSH command..."
ssh -i /root/.ssh/$4 -p "$2" -o StrictHostKeyChecking=no -F /root/.ssh/config "$3@$1" -v "$6"
