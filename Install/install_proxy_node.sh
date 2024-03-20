#!/bin/bash

default_proxy_login=user0001
default_proxy_passw=user0001
default_proxy_port='33128'


#Get proxy_login, proxy_passw, proxy_port
echo -n "Proxy login [$default_proxy_login]: "
read proxy_login
echo -n "Proxy password [$default_proxy_passw]: "
read proxy_passw
echo -n "Proxy port [$default_proxy_port]: "
read proxy_port

if [ -z $proxy_login ]; then
    proxy_login=$default_proxy_login
fi

if [ -z $proxy_passw ]; then
    proxy_passw=$default_proxy_passw
fi

if [ -z $proxy_port ]; then
    proxy_port=$default_proxy_port
fi


#Install basic packages
apt update -y
apt upgrade -y
apt install -y mc build-essential wget tar


#Install 3proxy
wget https://github.com/z3APA3A/3proxy/archive/0.9.4.tar.gz
tar -xvzf 0.9.4.tar.gz
cd 3proxy-0.9.4/
make -f Makefile.Linux
mkdir /etc/3proxy
mkdir -p /var/log/3proxy
cp bin/3proxy /usr/bin/
useradd -s /usr/sbin/nologin -U -M -r proxyuser
proxy_user_id=$(id -u proxyuser)
proxy_group_id=$(id -g proxyuser)
chown -R proxyuser:proxyuser /etc/3proxy
chown -R proxyuser:proxyuser /var/log/3proxy
chown -R proxyuser:proxyuser /usr/bin/3proxy
touch /etc/3proxy/3proxy.cfg
chmod 600 /etc/3proxy/3proxy.cfg


#Configuring 3proxy
echo 'users' $proxy_login':CL:'$proxy_passw > /etc/3proxy/3proxy.cfg
echo 'daemon' >> /etc/3proxy/3proxy.cfg
echo 'rotate 30' >> /etc/3proxy/3proxy.cfg
echo 'setgid' $proxy_user_id >> /etc/3proxy/3proxy.cfg
echo 'setuid' $proxy_group_id >> /etc/3proxy/3proxy.cfg
echo 'nserver 8.8.8.8' >> /etc/3proxy/3proxy.cfg
echo 'nserver 8.8.4.4' >> /etc/3proxy/3proxy.cfg
echo 'timeouts 1 5 30 60 180 1800 15 60' >> /etc/3proxy/3proxy.cfg
echo 'nscache 65536' >> /etc/3proxy/3proxy.cfg
echo 'flush' >> /etc/3proxy/3proxy.cfg
echo 'auth strong' >> /etc/3proxy/3proxy.cfg
echo 'allow' $proxy_login >> /etc/3proxy/3proxy.cfg
echo 'proxy -n -a -p'$proxy_port >> /etc/3proxy/3proxy.cfg
echo '' >> /etc/3proxy/3proxy.cfg


#Configuring iptables
iptables -F
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport $proxy_port -j ACCEPT
iptables -A OUTPUT -p tcp --sport $proxy_port -j ACCEPT


#Create 3proxy.service
touch /etc/systemd/system/3proxy.service
chmod 664 /etc/systemd/system/3proxy.service
echo '[Unit]' > /etc/systemd/system/3proxy.service
echo 'Description=3proxy Proxy Server' >> /etc/systemd/system/3proxy.service
echo 'After=network.target' >> /etc/systemd/system/3proxy.service
echo '' >> /etc/systemd/system/3proxy.service
echo '[Service]' >> /etc/systemd/system/3proxy.service
echo 'Type=simple' >> /etc/systemd/system/3proxy.service
echo 'ExecStart=/usr/bin/3proxy /etc/3proxy/3proxy.cfg' >> /etc/systemd/system/3proxy.service
echo 'ExecStop=/bin/kill `/usr/bin/pgrep proxyuser`' >> /etc/systemd/system/3proxy.service
echo 'RemainAfterExit=yes' >> /etc/systemd/system/3proxy.service
echo 'Restart=on-failure' >> /etc/systemd/system/3proxy.service
echo '' >> /etc/systemd/system/3proxy.service
echo '[Install]' >> /etc/systemd/system/3proxy.service
echo 'WantedBy=multi-user.target' >> /etc/systemd/system/3proxy.service
echo '' >> /etc/systemd/system/3proxy.service
systemctl start 3proxy
systemctl enable 3proxy


#Complete
echo ''
echo ''
echo ''
echo '--------------------------------------------------------------------------------'
echo 'Installation is complete'
echo "Proxy port: $proxy_port"
echo ""

