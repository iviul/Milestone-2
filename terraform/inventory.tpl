[public]
%{ for name, ip in public_ips ~}
%{ if ip != "" ~}
${name} ansible_host=${ip}
%{ endif ~}
%{ endfor ~}

[private]
%{ for name, ip in public_ips ~}
%{ if ip == "" ~}
${name} ansible_host=${private_ips[name]}
%{ endif ~}
%{ endfor ~}

[all:vars]
ansible_user = ubuntu

[private:vars]
ansible_ssh_common_args='-o ProxyJump=ubuntu@${public_ips["bastion"]}'
