#!/bin/bash

exec > >(sudo tee /var/log/startup-script.log) 2>&1
set -ex

USER_HOME="/home/ubuntu"
if [ ! -d "$USER_HOME" ]; then
  USER_HOME="/home/$(whoami)"
fi

# Creating SSH directory
mkdir -p $USER_HOME/.ssh
chmod 700 $USER_HOME/.ssh

# Adding SSH-keys into authorized_keys
cat <<EOF > $USER_HOME/.ssh/authorized_keys
${ssh_keys}
EOF

# Rights
chown $(basename $USER_HOME):$(basename $USER_HOME) $USER_HOME/.ssh/authorized_keys
chmod 600 $USER_HOME/.ssh/authorized_keys

# Update & install the Ops Agent
sudo apt-get update -y || { echo "apt-get update failed"; exit 1; }
sudo apt-get install -y curl gnupg || { echo "apt-get install failed"; exit 1; }
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh || { echo "curl failed"; exit 1; }
sudo bash add-google-cloud-ops-agent-repo.sh --also-install || { echo "Ops Agent install failed"; exit 1; }

# Start the Ops Agent
sudo systemctl restart google-cloud-ops-agent || { echo "Ops Agent restart failed"; exit 1; }
sudo systemctl status google-cloud-ops-agent --no-pager
