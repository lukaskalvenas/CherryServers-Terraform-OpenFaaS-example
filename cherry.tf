provider "cherryservers" { 
     auth_token = "eyJhbGciOiJIUzI1"
}

resource "cherryservers_project" "serverless_project" {
    team_id = "${var.team_id}"
    name = "${var.project_name}"
}

resource "cherryservers_ssh" "lukas" {
    name = "lukas"
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

    
    provisioner "file" {
      source = "docker-ce_17.12.0_ce-0_ubuntu_amd64.deb"
      destination = "/tmp/docker-ce_17.12.0_ce-0_ubuntu_amd64.deb"
  
      connection {
        type = "ssh"
        user = "root"
        host = "${cherryservers_server.serverless-master-server.primary_ip}"
        private_key = file(var.private_key)
      }
    }

    provisioner "remote-exec" {
      script = "install-openfaas.sh"

      connection {
        type = "ssh"
        user = "root"
        host = "${cherryservers_server.serverless-master-server.primary_ip}"
        private_key = file(var.private_key)
      }
    }

    provisioner "remote-exec" {
      inline = [
        "sudo dpkg -i /tmp/docker-ce_17.12.0_ce-0_ubuntu_amd64.deb; sudo apt install -f -y",
        "sudo apt -y install jq",
        "docker swarm init --advertise-addr ${cherryservers_server.serverless-master-server.primary_ip}",
        "sudo rm /tmp/docker-ce_17.12.0_ce-0_ubuntu_amd64.deb"
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
    provisioner "file" {
      source = "docker-ce_17.12.0_ce-0_ubuntu_amd64.deb"
      destination = "/tmp/docker-ce_17.12.0_ce-0_ubuntu_amd64.deb"
    
    connection {
      type = "ssh"
      user = "root"
      host = "${self.primary_ip}"
      private_key = file(var.private_key)
    }
    }
    provisioner  "remote-exec" {
      inline = [
        "sudo dpkg -i /tmp/docker-ce_17.12.0_ce-0_ubuntu_amd64.deb; sudo apt install -f -y",
        "sudo apt -y install jq",
        "docker swarm join --token ${data.external.swarm_join_token.result.worker} ${cherryservers_server.serverless-master-server.primary_ip}:2377",
        "sudo rm /tmp/docker-ce_17.12.0_ce-0_ubuntu_amd64.deb"
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
