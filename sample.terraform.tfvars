# GCP project info
project      = "yb"
control_name = "dev"
credentials  = "/opt/creds.json"

# ssh keys to connect to the bastion and replicated instances
ssh_private_key = "/opt/yb"
ssh_public_key  = "/opt/yb.pub"
ssh_user        = "ubuntu"
# key and cert for the replicated hostname; could be self-signed or ca signed
replicated_host_key  = "/opt/host_domain/key"
replicated_host_cert = "/opt/host_domain/cert"
license_key          = "opt/platform/portal.rli"
hostname             = "platformops"

# domain inputs
# name of the existing/new managed hosting zone. If it exists, then it would provision only the 'A' name records
# for the replicated instance(s). If the `dns_on` flag is off, then this zone should exists in the managed hosted zone
zone   = "yb"
domain = "nip.io"

dns_on = false

# The region name where the nodes should be spawned.
region = "asia-south1"

# vpc inputs
vpc_on = true
# if `vpc_on` is false, then `vpc_network` should already exist
vpc_network = "ybdp"

# bastion setting. # if the flag is not set, then this provisioning should be run from the google VPC network.
# Running it from the local machine would fail without a bastion instance
bastion_on = true

# flag to determine ha for the platform
ha_on = true

# unique identifier for the run. All the resources would have this identifier
identifier = "yugabyte"

# os image type
img_name    = "ubuntu-2004-focal-v20220610"
img_project = "ubuntu-os-cloud"
