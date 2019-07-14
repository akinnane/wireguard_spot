# Wireguard VPN in AWS

This is a Terraform module to ceate a WireGuard VPN server in AWS
using spot instances, and generate a client configuration to for
connecting to that VPN. For low traffic applications it could cost as
little as $1.29 a month.

## Module configuration
```
module "wireguard" {
  source    = "git@github.com:akinanne/wireguard_spot?ref=master//wireguard"
  ssh_key   = "ssh-rsa AAAA..."
  providers = {
    aws = "aws"
  }
}
```

## Start Wireguard
```
terraform init &&\
terraform apply -auto-approve &&\
sudo cp wg0.conf /etc/wireguard/wg0.conf &&\
sudo wg-quick up wg0
```

## Setup Android via QR code
```
qrencode -t ansi256 < wg0.conf
```

## Tear down
```
sudo wg-quick down wg0
terraform destroy -auto-approve
```
