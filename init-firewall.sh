#!/bin/bash
echo "Initializing firewall..."

iptables -F
iptables -X

iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

AI_PROVIDER_IP=$(getent hosts localai | awk '{print $1}' | head -n1)
if [ -n "$AI_PROVIDER_IP" ]; then
    iptables -A OUTPUT -d $AI_PROVIDER_IP -p tcp --dport 8080 -j ACCEPT
    echo "Whitelisted AI provider: $AI_PROVIDER_IP:8080"
else
    echo "WARNING: AI provider container not resolvable"
fi

SEARCH_PROVIDER_IP=$(getent hosts searchmcp | awk '{print $1}' | head -n1)
if [ -n "$SEARCH_PROVIDER_IP" ]; then
    iptables -A OUTPUT -d $SEARCH_PROVIDER_IP -p tcp --dport 8000 -j ACCEPT
    echo "Whitelisted Search provider: $SEARCH_PROVIDER_IP:8000"
else
    echo "WARNING: Search provider container not resolvable"
fi

iptables -L OUTPUT -n --line-numbers
