#!/bin/sh -l
export CF_ACCESS_CLIENT_ID="$7"
export CF_ACCESS_CLIENT_SECRET="$8"

# Add Host to SSH config
echo "Host $1" >> /root/.ssh/config

# Add ProxyCommand depending on token presence
if [ -z "$7" ] || [ -z "$8" ]; then
    echo "ProxyCommand cloudflared access ssh --hostname %h" >> /root/.ssh/config
else
    echo "ProxyCommand cloudflared access ssh --hostname %h --id $7 --secret $8" >> /root/.ssh/config
fi

# Set user
echo "User $3" >> /root/.ssh/config

# Save the private key
echo "$5" > /root/.ssh/$4
chmod 600 /root/.ssh/$4

# Scan and add host key
ssh-keyscan "$1" >> /root/.ssh/known_hosts

# Debug: show final config
cat /root/.ssh/config

# SSH command execution
ssh -i /root/.ssh/$4 -p "$2" -o StrictHostKeyChecking=no -F /root/.ssh/config "$3@$1" -v "$6"