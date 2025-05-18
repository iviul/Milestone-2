[public]
bastion ansible_host=${bastion_ip}

[private]
%{ for name, ip in private_ips ~}
%{ if name != "bastion" ~}
${name} ansible_host=${ip}
%{ endif ~}
%{ endfor ~}

[all:vars]
ansible_user = ubuntu
ansible_private_key_ssh=${private_key_path}

[private:vars]
ansible_ssh_common_args='-o ProxyJump=ubuntu@${bastion_ip}'

