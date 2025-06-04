[public]
%{ for name, ip in public_ips ~}
${name} ansible_host=${ip}
%{ endfor ~}

[all:vars]
ansible_user = ubuntu
ansible_private_key_ssh=${private_key_path}
%{ for name, dns in lb_dns_names ~}
dns_name=${dns}
%{ endfor ~}