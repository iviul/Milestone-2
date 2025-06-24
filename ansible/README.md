
# --- Run the playbook ---

# 1 · Production certificate (live Let’s Encrypt issuer)
ansible-playbook app_deploy.yml inventory/inventory.ini --ask-become-pass -e "env=production"

# 2 · Staging certificate (Let’s Encrypt staging issuer, safe for testing)
ansible-playbook app_deploy.yml inventory/inventory.ini --ask-become-pass -e "env=staging"
