#!/bin/bash
echo "configurando el resolv.conf con cat"
cat <<TEST> /etc/resolv.conf
nameserver 8.8.8.8
TEST

sudo lxc start haproxy

lxc exec haproxy -- sudo apt-get update && apt-get upgrade -y
lxc exec haproxy -- sudo apt-get autoremove -y
lxc exec haproxy -- sudo apt-get install haproxy -y
lxc exec haproxy -- sudo systemctl enable haproxy


sudo rm /etc/haproxy/haproxy.cfg;
cat <<TEST> /etc/haproxy/haproxy.cfg 
global
	log /dev/log	local0
	log /dev/log	local1 notice
	chroot /var/lib/haproxy
	stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
	stats timeout 30s
	user haproxy
	group haproxy
	daemon

	# Default SSL material locations
	ca-base /etc/ssl/certs
	crt-base /etc/ssl/private

	# Default ciphers to use on SSL-enabled listening sockets.
	# For more information, see ciphers(1SSL). This list is from:
	#  https://hynek.me/articles/hardening-your-web-servers-ssl-ciphers/
	# An alternative list with additional directives can be obtained from
	#  https://mozilla.github.io/server-side-tls/ssl-config-generator/?server=haproxy
	ssl-default-bind-ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:RSA+AES:!aNULL:!MD5:!DSS
	ssl-default-bind-options no-sslv3

defaults
    log    global
    mode    http
    option    httplog
    option    dontlognull
        timeout connect 5000
        timeout client  50000
        timeout server  50000
    errorfile 400 /etc/haproxy/errors/400.http
    errorfile 403 /etc/haproxy/errors/403.http
    errorfile 408 /etc/haproxy/errors/408.http
    errorfile 500 /etc/haproxy/errors/500.http
    errorfile 502 /etc/haproxy/errors/502.http
    errorfile 503 /etc/haproxy/errors/503.http
    errorfile 504 /etc/haproxy/errors/504.http

backend web-backend
   balance roundrobin
   stats enable
   stats auth admin:admin
   stats uri /haproxy?stats

   server web1 240.8.0.13:80 check
   server web2 240.9.0.40:80 check
   server web1backup 240.8.0.227:80 check backup
   server web2backup 240.9.0.229:80 check backup

frontend http
  bind *:80
  default_backend web-backend
TEST
sudo rm /etc/haproxy/errors/503.http
touch 503.http
echo "<html><body><h1>Failed server error 503</h1><p>El servidor no esta disponible, lo sentimos. Intente más tarde</p></body></html>" > 503.http
sudo cp 503.http  /etc/haproxy/errors/
systemctl start haproxy
systemctl restart haproxy

lxc config device add haproxy http proxy listen=tcp:192.168.100.7:5080 connect=tcp:127.0.0.1:80