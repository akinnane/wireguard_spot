provider "aws" {
  region = "eu-west-2"
}

module "wireguard" {
  source  = "./wireguard"
  ssh_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC4Hfl4q2i3cnoCIFCG4WqpRNCSgNNcDH9xqS2/zJTJVWYmiEuNkLB2EvVZS03FYh2oI005QzJFmtvZ8bN3tokb0YTXPG4u0NaEsdpElVz2D1icBJwiK+fbB8o7EGrZ3Yuw3huT/MV1uoipF8E8THui1aq95WlbZv0mD9lzHypb6zq5Iy59KG/y9zx//wX8CVUSQrELOQ/d2Nr8rWByOY12GFLfZdsJ52NYONPk/uKrLzozRjKArWQNqZWocskqdEbLzsZuJ8OOfb3uHMR7ulyQfng+PnbOvc0uLse3M4gNk6dOBV0P8Q62UG1sedrWJIo+Vf7Du1coqvNrXUW3P+FF"
  peers   = 3
  providers = {
    aws = "aws"
  }
}
