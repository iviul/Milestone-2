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

# Update & install the Ops Agent
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
scopes= [
 "https://www.googleapis.com/auth/monitoring.write",
 "https://www.googleapis.com/auth/logging.write"
]
