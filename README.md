![Cherry Servers](https://www.serchen.com/images/thumbnails/large/54097.jpg) 
# CherryServers-Terraform-OpenFaaS-example
This example will use Ubuntu as the base operating system to deploy one master node and a user-specified amount (e.g. three) worker nodes on Docker swarm. Those will then automatically join the master node via public IP address and Docker swarm token combination. 
# Requirements
<ul>
  <li><a href="https://download.docker.com/linux/ubuntu/dists/zesty/pool/stable/amd64/docker-ce_17.12.0~ce-0~ubuntu_amd64.deb" target="_blank">Docker CE<a> Copy it to the playbook's working directory</li>
  <li><a href="https://www.terraform.io/downloads.html" target="_blank">Terraform 0.12.6</a> Copy it to the playbook's working  directory.</li>
  <li><a href="http://downloads.cherryservers.com/other/terraform/" target="_blank">CherryServers Terraform module</a> Copy it to the playbook's working  directory.</li>
  <li><a href="https://stedolan.github.io/jq/download/" target="_blank">JQ package for the host PC/laptop</a></li>
</ul>

# Before you start
You will need a <a href="https://portal.cherryservers.com" target="_blank">cherrservers account</a> with credit in balance to order services with hourly billing. 

Create an API key at <a href="https://portal.cherryservers.com/#/settings/api-keys/" target="_blank">https://portal.cherryservers.com/#/settings/api-keys/</a> and enter it's value to "cherry.tf" file:<br>
```
$ vim Downloads/CherryServers-Terraform-OpenFaaS-example-master/cherry.tf

provider "cherryservers" { 
     auth_token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXUyJ9"
}
```

The "variables.tf" file is self explanatory and should be edited accordingly. Download and run the <a href="https://github.com/cherryservers/cherryctl" target="_blank">cherryctl</a> script to get a list of server plan IDs.
```
$ vim Downloads/CherryServers-Terraform-OpenFaaS-example-master/variables.tf

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
  default = "161"
}
variable "private_key" {
  default = "~/.ssh/id_rsa"
}
variable "public_key" {
  default = "~/.ssh/id_rsa.pub"
}
```
To set the worker count, edit the following line in the "cherry.tf" file:
```
################ Worker server ################
resource "cherryservers_server" "serverless-worker-server" {
    count = 3
.....
```
Make sure that all bash scripts in the Terraform working directory have an "execute" flag:

```
$ cd Downloads/CherryServers-Terraform-OpenFaaS-example-master
sudo chmod +x *.sh
sudo chmod +x terraform-provider-cherryservers
```
Last, but not least, check https://portal.cherryservers.com/#/settings/ssh-keys if you don't alredy have an SSH key with the same tag (name) uploaded or if there isn't already a project with the same name created at https://portal.cherryservers.com/#/projects, in which case Terraform will not run. Delete any duplicated SSH keys and/or projects and then run the task.

# Important

There've been situations where applying the API key directly into the "cherry.tf" file was not detected by the Cherry Servers API, so in that case you may need to manually export the API key using "export CHERRY_AUTH_TOKEN="API_key" command. 

# How to use

Before running Terraform, make sure you have the necessary files in the working directory
 
```
Downloads/CherryServers-Terraform-OpenFaaS-example-master$ tree .
.
├── cherry.tf
├── docker-ce_17.12.0_ce-0_ubuntu_amd64.deb
├── get-join-tokens.sh
├── install-openfaas.sh
├── outputs.tf
├── README.md
├── terraform
├── terraform-provider-cherryservers
└── variables.tf

0 directories, 9 files


```
Then, in the same directory, run the following commands
```
./terraform init
./terraform apply
```
In case you need detailed deploy/destroy output, execute the "export TF_LOG=trace" command on the working terminal session.

The full process may take up to 20 minutes to complete.

It will first deploy the master node and register all the necessary variables. Once that's done, the specified amount of worker servers will follow to deploy.

The worker servers will then be automatically added to the Docker swarm. When the playbook finishes, log into the master node, change the working directory to "~/faas" and run the following commands
```
git checkout 0.8.9
./deploy_stack.sh
```

This will install the default OpenFaaS function stack for you. Use the provided login credentials to access the master GUI control panel at http://$master_ip:8080 and begin working. Alternatively, you can use the OpenFaaS CLI tools to perform the tasks from the terminal.

Good luck!

# When no longer needed
```
./terraform destroy
```
Keep in mind that all Docker swarm members will be terminated and the data will get permanently wiped.
