# GCP project info
project       = "yb"
control_name  = "dev"

# key pair
credentials     = "/opt/creds.json"
ssh_private_key = "/opt/yb"
ssh_public_key  = "/opt/yb.pub"
ssh_user        = "ubuntu"

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
