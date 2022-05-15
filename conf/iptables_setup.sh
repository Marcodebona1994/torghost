#!/bin/bash

NON_TOR="192.168.0.0/16 172.16.0.0/12 127.0.0.0/8 10.0.0.0/8"
TOR_UID=$(id -ur debian-tor)
TRANS_PORT="9040"

iptables -F
iptables -t nat -F

iptables -t nat -A OUTPUT -m owner --uid-owner $TOR_UID -j RETURN
iptables -t nat -A OUTPUT -p udp --dport 53 -j REDIRECT --to-ports 5353
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

for NET in $NON_TOR; do
 iptables -t nat -A OUTPUT -d $NET -j RETURN
 iptables -A OUTPUT -d $NET -j ACCEPT
done
iptables -t nat -A OUTPUT -p tcp --syn -j REDIRECT --to-ports $TRANS_PORT

iptables -A OUTPUT -m owner --uid-owner $TOR_UID -j ACCEPT
iptables -A OUTPUT -j REJECT
