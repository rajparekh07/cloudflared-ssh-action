#!/bin/sh -l

# Set CF Access token to ENV so cloudflared can use it automatically
export CF_ACCESS_CLIENT_ID="$7"
export CF_ACCESS_CLIENT_SECRET="$8"

# Add Host to SSH config
echo "Host $1" >> /root/.ssh/config

# Add ProxyCommand (no --id/--secret since env is used)
echo "ProxyCommand cloudflared access ssh --hostname %h" >> /root/.ssh/config

# Set SSH user
echo "User $3" >> /root/.ssh/config

# Save the private key
echo "$5" > /root/.ssh/$4
chmod 600 /root/.ssh/$4

# Add host to known_hosts
ssh-keyscan "$1" >> /root/.ssh/known_hosts

# Debug output
cat /root/.ssh/config

# Execute SSH command using the config
ssh -i /root/.ssh/$4 -p "$2" -o StrictHostKeyChecking=no -F /root/.ssh/config "$3@$1" -v "$6"