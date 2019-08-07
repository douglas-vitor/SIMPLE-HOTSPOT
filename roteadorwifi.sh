#!/bin/bash
#################
#Script de roteador wifi automatico
#v 1.0
#################

while true; do
read -p 'Digite sua placa wifi para colocar em monitoramento: ex. wlan0 : ' AIR
case $AIR in

wlan0 ) airmon-ng start wlan0 ;;
wlan1 ) airmon-ng start wlan1 ;;
wlan2 ) airmon-ng start wlan2 ;;
wlan3 ) airmon-ng start wlan3 ;;
wlan4 ) airmon-ng start wlan4 ;;
wlan5 ) airmon-ng start wlan5 ;;
* ) echo "valor errado" ;;
esac
break
done

xterm -e airbase-ng -e WifiTMP -c 6 -P "$AIR"mon &

sleep 5
echo "#!/bin/bash

ifconfig at0 up
ifconfig at0 192.168.2.1/24
route add -net 192.168.2.0 netmask 255.255.255.0 gw 192.168.2.1
exit 0

" > /tmp/at0up.sh
sleep 5
chmod +x /tmp/at0up.sh
/tmp/./at0up.sh

rm /tmp/at0up.sh &&

echo "configurando arq. /etc/dhcpd.conf"
echo "authoritative;
default-lease-time 600;
max-lease-time 7200;
subnet 192.168.2.0 netmask 255.255.255.0 {
option subnet-mask 255.255.255.0;
option broadcast-address 192.168.2.255;
option routers 192.168.2.1;
option domain-name-servers 8.8.8.8;
range 192.168.2.100 192.168.2.175; 
}" > /etc/dhcpd.conf
sleep 5

echo "exportando pid"
dhcpd -cf /etc/dhcpd.conf -pf /var/run/dhcpd.pid at0

echo "startando servidos DHCP"
/etc/init.d/isc-dhcp-server start

echo "permitindo redirecionamento de portas"
echo 1 > /proc/sys/net/ipv4/ip_forward

echo "aplicando regras no iptables"
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain
iptables --table nat --append POSTROUTING --out-interface eth0 -j MASQUERADE
iptables --append FORWARD --in-interface at0 -j ACCEPT

echo "roteador pronto!"
exit 0

