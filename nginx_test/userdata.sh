#!/bin/bash
apt update -y &&
apt install -y nginx
systemctl start nginx
systemctl enable nginx
echo "<h3>Hi How are you doing, hope you are good<h3>" > /var/www/html/index.html