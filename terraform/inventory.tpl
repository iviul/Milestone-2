[public]
%{ for name, ip in public_ips ~}
${name} ansible_host=${ip} ansible_host_private=${private_ips[name]}
%{ endfor ~}

[all:vars]
ansible_user = ubuntu
ansible_private_key_ssh=${private_key_path}
%{ for name, dns in lb_dns_names ~}
${name}=${dns}
%{ endfor ~}
db_host=${db_host}
db_user=${db_user} 
db_password=${db_password} 
db_port=${db_port} 
db_name=${db_name} 
