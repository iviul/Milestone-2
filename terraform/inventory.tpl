[private]
%{ for name, ip in private_ips ~}
${name} ansible_host=${ip}
%{ endfor ~}

[all:vars]
ansible_user = ubuntu
ansible_private_key_ssh=${private_key_path}
