[all:vars]
db_host=${db_host}
db_user=${db_user}
db_password=${db_password}
db_port=${db_port}
db_name=${db_name}

[static_ips]
%{ for name, ip in static_ips }
${name}=${ip}
%{ endfor }
