#!/bin/bash
# Install WG
add-apt-repository -y ppa:wireguard/wireguard
apt install -y wireguard

# Enable forwarding
cat >> /etc/sysctl.conf << EF
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
EF

sysctl -p

# Configure WG
cat > /etc/wireguard/wg0.conf << EF
[Interface]
PrivateKey = ${server_private_key}
Address = 10.200.200.1/24
ListenPort = 443
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o ens5 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o ens5 -j MASQUERADE
SaveConfig = true

# Add extra peers here
[Peer]
PublicKey = ${client_public_key}
AllowedIPs = 10.200.200.2/32
PersistentKeepalive = 25
EF

systemctl enable wg-quick@wg0
wg-quick up wg0
wg show
