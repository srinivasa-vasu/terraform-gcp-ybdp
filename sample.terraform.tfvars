# GCP project info
project      = "yb"
control_name = "dev"
credentials     = "/opt/creds.json"

# ssh keys to connect to the bastion and replicated instances
ssh_private_key = "/opt/yb"
ssh_public_key  = "/opt/yb.pub"
ssh_user        = "ubuntu"
# key and cert for the replicated hostname; could be self-signed or ca signed
replicated_host_key ="/opt/host_domain/key"
replicated_host_cert ="/opt/host_domain/cert"
hostname = "platformops"

# The region name where the nodes should be spawned.
region = "asia-south1"

# vpc inputs
vpc_on = true
# if `vpc_on` is false, then `vpc_network` should already exist 
vpc_network = "ybdp"

# bastion setting
bastion_on = true

# domain inputs
dns_on = true
domain = "nip.io"

# unique identifier for the run. All the resources would have this identifier
identifier = "yugabyte"
