[public]
%{ for name, ip in public_ips ~}
${name} ansible_host=${ip} ansible_host_private=${private_ips[name]}
%{ endfor ~}

[all:vars]
ansible_user = ubuntu
ansible_private_key_ssh=${private_key_path}

