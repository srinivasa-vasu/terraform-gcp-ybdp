# terraform-gcp-ybdp

A terraform module to deploy and manage Yugabyte data platform(ybdp) in the Google cloud

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
# GCP project info
project       = "# gcp project id"
control_name  = "# ybdp control plane name"

# key pair
credentials     = "# gcp service account credential file path"
ssh_private_key = "# ssh private key file path"
ssh_public_key  = "# ssh public key file path"
ssh_user        = "# ssh user name"

region = "# region name where the node(s) should be spawned"

# vpc inputs
vpc_on = "# if 'true', resources would be provisioned in the existing vpc; if not, will create a new vpc"
vpc_network      = "# vpc network name; existing/new network name"

# bastion host setting
bastion_on   = "# flag to spawn host. set to 'true' if the access to ybdp is through the bastion host"

# domain inputs
dns_on = "# if true, would create a new managed hosted zone"
domain = "# domain name like nip.io"

identifier       = "# unique identifier for the run. All the resources would have this identifier"
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