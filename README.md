# terraform-gcp-ybdp

A terraform module to deploy and manage Yugabyte data platform(ybdp) in the Google cloud

## Initialization
* Clone this repo to the local workstation

```
$ git clone https://github.com/srinivasa-vasu/terraform-gcp-ybdp.git
```

* Change directory to the cloned repo

```
$ cd terraform-gcp-ybdp
```

* Create `terraform.tfvars` file with the following info populated

```   
# GCP project info
project       = "# gcp project id"
control_name  = "# ybdp control plane name"

# key pair.
credentials     = "# gcp service account credential file path"
ssh_private_key = "# ssh private key file path"
ssh_public_key  = "# ssh public key file path"
ssh_user        = "# ssh user name"

region = "# region name where the node(s) should be spawned"

use_existing_vpc = "# if 'true', resources would be provisioned in the existing vpc; if not, will create a new vpc"
vpc_network      = "# vpc network name; existing/new network name"
identifier       = "# identifier to prefix in the created resources"
bastion_create   = "# flag to spawn host. set to 'true' if the access to ybdp is through the bastion host"
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