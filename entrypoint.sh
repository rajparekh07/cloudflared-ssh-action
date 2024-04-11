#!/bin/sh -l

echo "Preparing Config"

echo "Host $1" >> /root/.ssh/config
echo "ProxyCommand cloudflared access ssh --hostname %h" >> /root/.ssh/config


echo "Preparing Key"

echo "$4" > /root/.ssh/key.pem
chmod 600 /root/.ssh/key.pem

echo "Preparing SSH"

ssh-keyscan $1 >> /root/.ssh/known_hosts

ssh -o StrictHostKeyChecking=no $3@$1

echo "SSHing begins"
ssh -i /root/.ssh/key.pem $3@$1 -p $2 -vvv "$5"
