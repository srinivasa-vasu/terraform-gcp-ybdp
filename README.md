# terraform-gcp-ybdp

A GCP Terraform module to deploy and manage the Yugabyte data platform(ybdp)

## Pre-requisites

Following IAM roles are required for the Service Account

- Compute Admin
- DNS Administrator
- Service Account Admin
- Service Account User

## Initialization
* Clone this repo to the local workstation

```
$ git clone https://github.com/srinivasa-vasu/terraform-gcp-ybdp.git
```

* Change directory to the cloned repo

```
$ cd terraform-gcp-ybdp
```

* Create `terraform.tfvars` file with the following info populated (or update `sample.terraform.tfvars` file appropriately and rename it to `terraform.tfvars`)

```
-----------------------------------------------mandatory inputs-----------------------------------------------
# GCP project info
project         = "# gcp project id"
control_name    = "# ybdp control plane name"
credentials     = "# gcp service account credential file path"

# ssh keys to connect to the bastion and replicated instances
ssh_private_key = "# ssh private key file path"
ssh_public_key  = "# ssh public key file path"
ssh_user        = "# ssh user name"
# key and cert for the replicated hostname; could be self-signed or ca signed
host_key     = "# replicated instance host private key path"
host_cert    = "# replicated instance host cert path"
license_key             = "# platform license key path"
hostname                = "# replicated instance host name; this will be suffixed with the `domain` name; just mention the hostname without the domain"

# domain inputs
zone   = "# name of the existing/new zone"
domain = "# domain name like nip.io"
-----------------------------------------------mandatory inputs-----------------------------------------------
dns_on = "# if true, would create a new managed hosted zone"


region = "# region name where the node(s) should be spawned"

# vpc inputs
vpc_on              = "# if 'true', resources would be provisioned in the existing vpc; if not, will create a new vpc and 2 subnets; 1 for management instances and the other for the universe"
vpc_network         = "# vpc network name; existing/new network name"

# bastion host setting
bastion_on   = "# flag to spawn host. set to 'true' if the access to ybdp is through the bastion host"

ha_on = "# flag to determine ha for the platform"

identifier  = "# unique identifier for the run. All the resources would have this identifier"
```


## Usage

* Run terraform init to initialize the modules dependencies

```
$ terraform init
```

* Generate the terraform plan to understand the changes

```
$ terraform plan -out=plan
```

* Run the following to apply the changes

```
$ terraform apply plan
```

* Run the following the fetch the values from the terraform run

```
$ terraform output <output_variable>
```

* To destroy the provisioned resources,

```
$ terraform destroy
```

## Managed Resources

This terraform-module manages the following GCP resources

- vpc
- subnets
- hosted zone
- load balancer
- compute instances
- nat router
- firewall