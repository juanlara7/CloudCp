#!/bin/bash
echo "configurando el resolv.conf con cat"
cat <<TEST> /etc/resolv.conf
nameserver 8.8.8.8
TEST

sudo lxc start web1
lxc exec web1 -- sudo apt update && apt upgrade -y
lxc exec web1 -- sudo apt-get install apache2 -y
lxc exec web1 -- sudo systemctl enable apache2
touch index.html;
echo "<html><body><h1>FROM WEB1</h1>
<img src="https://cdn.pixilart.com/photos/large/dc681bf8ffc46c2.png" width="640"></body></html>" > index.html
sudo lxc file push index1.html web1/var/www/html/index.html
lxc exec web1 -- sudo systemctl restart apache2
lxc exec web1 -- sudo service apache2 restart

sudo lxc start web1backup
lxc exec web1backup -- sudo apt update && apt upgrade -y
lxc exec web1backup -- sudo apt-get install apache2 -y
lxc exec web1backup -- sudo systemctl enable apache2
lxc exec web1backup -- sudo rm /var/www/html/index.html
touch index.html
echo "<html><body><h1>FROM WEB1 BACKUP</h1>
<img src="https://cdn.pixilart.com/photos/large/dc681bf8ffc46c2.png" width="640"></body></html>"> index.html
sudo lxc file push index.html web1backup/var/www/html/index.html
lxc exec web1backup -- sudo systemctl restart apache2
lxc exec web1backup -- sudo service apache2 restart