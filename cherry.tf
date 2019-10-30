provider "cherryservers" { 
     auth_token = "eyJhbGciO"
}

resource "cherryservers_project" "serverless_project" {
    team_id = "${var.team_id}"
    name = "${var.project_name}"
}

resource "cherryservers_ssh" "openfaas_terraform" {
    name = "openfaas_terraform"
    public_key = file(var.public_key)
}

################ Master server creation ################

resource "cherryservers_server" "serverless-master-server" {
    project_id = "${cherryservers_project.serverless_project.id}"
    region = "${var.region}"
    hostname = "serverless-master-server"
    image = "${var.image}"
    plan_id = "${var.plan_id}"
    ssh_keys_ids = ["${cherryservers_ssh.lukas.id}"]
    
    provisioner "remote-exec" {
      inline = [
        "cd /tmp",
        "wget https://download.docker.com/linux/ubuntu/dists/zesty/pool/stable/amd64/docker-ce_17.12.0~ce-0~ubuntu_amd64.deb",
        "sudo DEBIAN_FRONTEND=noninteractive apt install -y /tmp/docker-ce_17.12.0~ce-0~ubuntu_amd64.deb curl git jq",
        "docker swarm init --advertise-addr ${cherryservers_server.serverless-master-server.primary_ip}",
        "cd ~",   
        "sudo git clone https://github.com/openfaas/faas.git",
        "sudo curl -sSL -o faas-cli.sh https://cli.openfaas.com",
        "sudo chmod +x faas-cli.sh",
        "sudo ./faas-cli.sh"
      ]    

      connection {
        type = "ssh"
        user = "root"
        host = "${cherryservers_server.serverless-master-server.primary_ip}"
        private_key = file(var.private_key)
      }
    }
    
}
################ Worker server ################
resource "cherryservers_server" "serverless-worker-server" {
    count = 3
    project_id = "${cherryservers_project.serverless_project.id}"
    region = "${var.region}"
    hostname = "serverless-worker-server${count.index}"
    image = "${var.image}"
    plan_id = "${var.plan_id}"
    ssh_keys_ids = ["${cherryservers_ssh.lukas.id}"]
    connection {
      type = "ssh"
      user = "root"
      host = "${cherryservers_server.serverless-worker-server.primary_ip}"
      private_key = file(var.private_key)
    }

    provisioner  "remote-exec" {
      inline = [
        "cd /tmp",
        "wget https://download.docker.com/linux/ubuntu/dists/zesty/pool/stable/amd64/docker-ce_17.12.0~ce-0~ubuntu_amd64.deb",
        "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y /tmp/docker-ce_17.12.0~ce-0~ubuntu_amd64.deb jq",
        "docker swarm join --token ${data.external.swarm_join_token.result.worker} ${cherryservers_server.serverless-master-server.primary_ip}:2377",
      ]
    connection {
       type = "ssh"
       user = "root"
       host = "${self.primary_ip}"
       private_key = file(var.private_key)
    }
    }
   
  }
data "external" "swarm_join_token" {
  program = ["./get-join-tokens.sh"]
  query = {
    host = "${cherryservers_server.serverless-master-server.primary_ip}"
  }
 }
