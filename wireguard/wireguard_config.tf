resource "null_resource" "keys_server" {
  triggers = {
    build_number = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "wg genkey | tee server_privatekey | wg pubkey > server_publickey"
    working_dir = ".tmp"
  }
}

resource "null_resource" "keys_client" {
  triggers = {
    build_number = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "wg genkey | tee client_privatekey | wg pubkey > client_publickey"
    working_dir = ".tmp"
  }
}

data "local_file" "server_private_key" {
  depends_on = [null_resource.keys_server]
  filename   = "./.tmp/server_privatekey"
}

data "local_file" "server_public_key" {
  depends_on = [null_resource.keys_server]
  filename   = "./.tmp/server_publickey"
}

data "local_file" "client_private_key" {
  depends_on = [null_resource.keys_client]
  filename   = "./.tmp/client_privatekey"
}

data "local_file" "client_public_key" {
  depends_on = [null_resource.keys_client]
  filename   = "./.tmp/client_publickey"
}

data "template_file" "user_data" {
  template = "${file("${path.module}/init.sh")}"
  vars = {
    server_private_key = data.local_file.server_private_key.content
    client_public_key  = data.local_file.client_public_key.content
    client_ip          = data.http.myip.body
  }
}

data "http" "myip" {
  url = "http://ifconfig.me"
}

data "template_file" "client_conf" {
  template = "${file("${path.module}/client.conf")}"
  vars = {
    client_private_key = data.local_file.client_private_key.content
    server_public_key  = data.local_file.server_public_key.content
    server_ip          = aws_spot_instance_request.wireguard.public_ip
  }
}

resource "local_file" "client_conf" {
  content  = data.template_file.client_conf.rendered
  filename = "wg0.conf"
}

output "run_this" {
  value = "sudo cp wg0.conf /etc/wireguard/wg0.conf; sudo wg-quick up wg0"
}
