resource "null_resource" "keys_server" {
  triggers = {
    build_number = "${timestamp()}"
  }
  provisioner "local-exec" {
    command     = "wg genkey | tee server_privatekey | wg pubkey > server_publickey"
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

# data "template_file" "user_data" {
#   template = "${file("${path.module}/init.sh")}"
#   vars = {
#     server_private_key = data.local_file.server_private_key.content
#     client_public_key = [
#       for peer in data.local_file.client_public_key :
#       peer.content
#     ]
#   }
# }
