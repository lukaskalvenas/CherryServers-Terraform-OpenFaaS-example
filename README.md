![Cherry Servers](https://www.serchen.com/images/thumbnails/large/54097.jpg) 
# CherryServers-Terraform-OpenFaaS-example
This example will use Ubuntu as the base operating system to deploy one master node and a user-specified amount (e.g. two) worker nodes via Docker swarm. Those will then automatically join the master node via public IP address and Docker swarm token combination. 
# Prerequisites
<ul>
  <li><a href="https://www.terraform.io/downloads.html" target="_blank">Terraform 0.12.6</a></li>
  <li><a href="http://downloads.cherryservers.com/other/terraform/" target="_blank">CherryServers Terraform module</a> Copy it to the working Terraform directory.</li>
  <li><a href="https://stedolan.github.io/jq/download/" target="_blank">JQ package for the host PC/laptop</a></li>
</ul>

# Before you start
You will need a <a href="https://portal.cherryservers.com" target="_blank">cherrservers account</a> with credit in balance to order services with hourly billing. 

Create an API key at <a href="https://portal.cherryservers.com/#/settings/api-keys/" target="_blank">https://portal.cherryservers.com/#/settings/api-keys/</a> and enter it's value to "cherry.tf" file:<br>
```
provider "cherryservers" { 
     auth_token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXUyJ9"
}
```
# Important

There've been situations where applying the API key directly into the ".tf" file was not detected by the Cherry Servers API, so in that case you may need to manually export the API key using "export CHERRY_AUTH_TOKEN="API_key" command. Download and run the <a href="https://github.com/cherryservers/cherryctl" target="_blank">cherryctl</a> script to get a list of server plan IDs.

The "variables.tf" file is self explanatory and should be edited accordingly:
```
# User Variables
variable "region" {
  default = "EU-East-1"
}
variable "image" {
  default = "Ubuntu 16.04 64bit"
}
variable "project_name" {
  default = "OpenFaaSProject1"
}
variable "team_id" {
  default = "11682"
}
variable "plan_id" {
  default = "94"
}
variable "private_key" {
  default = "~/.ssh/id_rsa"
}
variable "public_key" {
  default = "~/.ssh/id_rsa.pub"
}
```
To set the worker count, edit the 64th line in the "cherry.tf" file:
```
################ Worker server ################
resource "cherryservers_server" "serverless-worker-server" {
    count = 3
.....
```
# How to use

First and foremost, make sure that both "terraform" main script and CherryServers terraform module files are present in the working directory. 

```
./terraform init
./terraform plan
./terraform apply
```
In case you need detailed deploy/destroy output, execute the "export TF_LOG=trace" command on the working terminal session.

The full process may take up to 20 minutes to complete.

It will first deploy the master node and register all the necessary variables. Once that's done, the specified amount of worker servers will follow to deploy.

The worker servers will then be automatically added to the Docker swarm. When the playbook finishes, log into the master node, change the working directory to "~/faas" and run the "deploy_stack.sh" script.

This will install the default OpenFaaS function stack for you. Use the provided login credentials to access the master GUI control panel at http://$master_ip:8080 and begin working.

Good luck!

# When no longer needed
```
./terraform destroy
```
Keep in mind that all Docker swarm members will be terminated and the data will get permanently wiped.
