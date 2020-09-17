#!/bin/bash
echo "configurando el resolv.conf con cat"
cat <<TEST> /etc/resolv.conf
nameserver 8.8.8.8
TEST
sudo lxc start web2
lxc exec web2 -- sudo apt update && apt upgrade -y

lxc exec web2 -- sudo apt-get install apache2 -y
sudo systemctl enable apache2
lxc exec web2 -- sudo rm /var/www/html/index.html
touch index.html
echo "<html><body><h1>FROM WEB2</h1>
<img src="https://cdn.pixilart.com/photos/large/dc681bf8ffc46c2.png" width="640"></body></html>" > index.html
sudo lxc file push index.html web2/var/www/html/index.html
lxc exec web2 -- sudo systemctl restart apache2
lxc exec web2 -- sudo service apache2 start

sudo lxc start web2backup
lxc exec web2backup -- sudo apt update && apt upgrade -y
lxc exec web2backup -- echo "Install apache2 service"
lxc exec web2backup -- sudo apt-get install apache2 -y
lxc exec web2backup -- sudo systemctl enable apache2
lxc exec web2backup -- sudo rm /var/www/html/index.html
touch index.html
echo "<html><body><h1>FROM WEB2 BACKUP</h1>
<img src="https://cdn.pixilart.com/photos/large/dc681bf8ffc46c2.png" width="640"></body></html>" > index.html
sudo lxc file push index.html web2backup/var/www/html/index.html
lxc exec web2backup -- sudo systemctl restart apache2
lxc exec web2backup -- sudo service apache2 start

