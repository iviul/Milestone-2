#!/bin/bash

# Creating SSH directory
mkdir -p /home/ubuntu/.ssh
chmod 700 /home/ubuntu/.ssh

# Adding SSH-keys into authorized_keys
cat <<EOF > /home/ubuntu/.ssh/authorized_keys
${ssh_keys}
EOF


# Rights
chown ubuntu:ubuntu /home/ubuntu/.ssh/authorized_keys
chmod 600 /home/ubuntu/.ssh/authorized_keys

# Ensure Python3 is installed
if ! command -v python3 >/dev/null 2>&1; then
  apt-get update && apt-get install -y python3
fi

# Start a simple HTTP server on port 6443 for health checks
nohup python3 -m http.server 6443 --bind 0.0.0.0 >/var/log/healthcheck.log 2>&1 &