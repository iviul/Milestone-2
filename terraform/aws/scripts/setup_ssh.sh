#!/bin/bash

USERNAME="ubuntu"
CONFIG_URL="https://github.com/iviul/Config/blob/DI-36-Update-config-with-artifact-registors-and-public-keys/config.json"

# Creating user
if ! id "$USERNAME" &>/dev/null; then
    useradd -m "$USERNAME"
fi

# SSH directory
SSH_DIR="/home/$USERNAME/.ssh"
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"
touch "$SSH_DIR/authorized_keys"
chmod 600 "$SSH_DIR/authorized_keys"
chown -R "$USER:$USER" "$SSH_DIR"


# Download config
curl -s "$CONFIG_URL" -o /tmp/config.json

# Installing jq
command -v jq >/dev/null 2>&1 || apt-get update && apt-get install -y jq || yum install -y jq

# Adding authorized_keys
jq -r '.keys[]' /tmp/config.json | while read -r key; do
  grep -qxF "$key" "$SSH_DIR/authorized_keys" || echo "$key" >> "$SSH_DIR/authorized_keys"
done

chown "$USER:$USER" "$SSH_DIR/authorized_keys"

echo "SSH keys added to $USER"



