output "master_public_ip" {
  value = "${cherryservers_server.serverless-master-server.primary_ip}"
}

output "worker_server_public_ip" {
  value= ["${cherryservers_server.serverless-worker-server.*.primary_ip}"]
}
