# Wireguard VPN in AWS

This is a Terraform module to ceate a wiregurad VPN server in AWS
using spot instances, and a generate a client configuration to for
that server. For low traffic applications it could cost as little as
$1.29 a month.

```
module "wireguard" {
  source    = "git@github.com:akinanne/wireguard_spot?ref=master"
  ssh_key   = "ssh-rsa AAAA..."
  providers = {
    aws = "aws"
  }
}
```

```
terraform init &&\
terraform apply -auto-approve &&\
sudo cp wg0.conf /etc/wireguard/wg0.conf &&\
sudo wg-quick up wg0
```
