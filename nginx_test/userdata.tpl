#!/bin/bash
apt update -y &&
apt install -y nginx
systemctl start nginx
systemctl enable nginx
echo "Hi How are you doing, hope you are good" > /var/www/html/index.html