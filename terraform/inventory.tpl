[private]
%{ for name, ip in private_ips ~}
%{ if name != "bastion" ~}
${name} ansible_host=${ip}
%{ endif ~}
%{ endfor ~}

[bastion]
bastion ansible_host=${bastion_ip}

[all:vars]
ansible_user = ubuntu
ansible_private_key_ssh=${private_key_path}



db_host=${db_host}
db_user=${db_user} 
db_password=${db_password} 
db_port=${db_port} 
db_name=${db_name}
%{ for name, ip in lb_ips ~}
${name}=${ip}
%{ endfor ~}



[private:vars]
ansible_ssh_common_args='-o ProxyJump=ubuntu@${bastion_ip}'

