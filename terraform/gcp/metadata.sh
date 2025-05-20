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