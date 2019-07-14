resource "null_resource" "keys_client" {
  count = var.peers
  triggers = {
    build_number = "${timestamp()}"
  }
  provisioner "local-exec" {
    command     = "wg genkey | tee client_privatekey${count.index} | wg pubkey > client_publickey${count.index}"
    working_dir = ".tmp"
  }
}

data "local_file" "client_private_key" {
  count      = var.peers
  depends_on = [null_resource.keys_client]
  filename   = "./.tmp/client_privatekey${count.index}"
}

data "local_file" "client_public_key" {
  count      = var.peers
  depends_on = [null_resource.keys_client]
  filename   = "./.tmp/client_publickey${count.index}"
}

resource "local_file" "client_conf" {
  count = var.peers
  content = templatefile(
    "${path.module}/client.conf",
    {
      client_private_key = data.local_file.client_private_key[count.index]
      server_public_key  = data.local_file.server_public_key.content
      server_ip          = aws_spot_instance_request.wireguard.public_ip
      index              = count.index
    }
  )
  filename = "wg${count.index}.conf"
}
