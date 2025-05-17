#!/bin/bash

USERNAME="ubuntu"
CONFIG_URL="https://github.com/iviul/Config/blob/DI-36-Update-config-with-artifact-registors-and-public-keys/config.json?raw=true"

# Create user if it doesn't exist
if ! id "$USERNAME" &>/dev/null; then
    echo "Creating user $USERNAME"
    sudo adduser --disabled-password --gecos "" "$USERNAME"
else
    echo "User $USERNAME already exists"
fi

# SSH directory setup
SSH_DIR="/home/$USERNAME/.ssh"
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"
touch "$SSH_DIR/authorized_keys"
chmod 600 "$SSH_DIR/authorized_keys"
chown -R "$USERNAME:$USERNAME" "$SSH_DIR"

# Download config.json
curl -L -o "$SSH_DIR/config.json" "$CONFIG_URL"

# Install jq if not present
if ! command -v jq &>/dev/null; then
    echo "Installing jq..."
    apt-get update && apt-get install -y jq
fi

# Extract and add SSH keys
jq -r '.ssh_keys[] | .key' "$SSH_DIR/config.json" | while read -r key; do
    if ! grep -q "$key" "$SSH_DIR/authorized_keys"; then
        echo "Adding SSH key to authorized_keys"
        echo "$key" >> "$SSH_DIR/authorized_keys"
    fi
done

chown "$USERNAME:$USERNAME" "$SSH_DIR/authorized_keys"

echo "Startup script completed. SSH keys added for $USERNAME."
