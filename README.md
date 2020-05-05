# AWS kubeadm module

Terraform module for creating a Kubernetes cluster on AWS with kubeadm.

## Description

This module creates the necessary AWS infrastructure for running a Kubernetes cluster and installs Kubernetes on this infrastructure with kubeadm.

The goal of this module is to get a brand-new bootstrapped cluster up and running quickly.

## Intended use

The intended use of the cluster created by this module is for **experiments** and not for production, because the cluster contains only a single master node.

The provisioning of the cluster stops right after bootstrapping with kubeadm. That means, **no CNI plugin** is automatically installed.

This is intentional, because it provides you the maximum flexibility to configure of the cluster — for example, by installing a custom CNI plugin.

## Quick usage

First, ensure the [prerequisites](#prerequisites) below.

Use the module in your `main.tf` configuration file as follows:

```hcl
provider "aws" {
  region = "eu-central-1"
}

module "cluster" {
  source  = "weibeld/kubeadm/aws"
  version = "0.0.2"
  private_key_file = "~/.ssh/id_rsa"
  public_key_file  = "~/.ssh/id_rsa.pub"
}

output "kubeconfig" {
  value = module.cluster.kubeconfig
}
```

Initialise the configuration:

```bash
terraform init
```

Apply the configuration:

```bash
terraform apply
```

This command creates the cluster and produces a single output value named `kubeconfig`. This is the location of the kubeconfig file of your newly created cluster on your local machine.

You can now access your cluster by using this kubeconfig file as follows:

```bash
kubectl --kubeconfig <your-cluster.conf> get nodes
```

You can also set the `KUBECONFIG` environment variable so that you don't need to use the `--kubeconfig` flag for every kubectl command:

```bash
export KUBECONFIG=<your-cluster.conf>
```

> Note that the nodes of a freshly created cluster are in the `NotReady` status. This is because no CNI plugin has been installed yet.

At this point, you can install a CNI plugin in your cluster to render the cluster functional.

To delete the cluster and all related AWS infratructure, run:

```bash
terraform destroy
```

_For more detailed usage examples, see the [examples](examples) directory._

## Prerequisites

To be able to use the module, you have to ensure the following prerequisites.

### Install Terraform

You can install Terraform on your system according to the [Terraform documentation](https://www.terraform.io/downloads.html).

> On macOS, you can install Terraform simply with `brew install terraform`.

### Configure AWS credentials

For Terraform being able to acces your AWS account, you have to provide your **AWS Access Key ID** and **AWS Secret Access Key** to Terraform.

You can do this in one of the two following ways:

1. Create an `~/.aws/credentials` file which is done automatically for you by running the follwoing command for [configuring the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html):
    ```bash
    aws configure
    ```
2. Set the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` [environment variables](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html):
    ```bash
    export AWS_ACCESS_KEY_ID=<AccessKeyID>
    export AWS_SECRET_ACCESS_KEY=<SecretAccessKey>
    ```

### Prepare a public/private key pair

The module configures SSH access to the nodes of your cluster through a public/private key pair that you provide.

You can use _any_ key pair for this. For example, it's completely valid to use the OpenSSH default key pair:

- `~/.ssh/id_rsa` (private key)
- `~/.ssh/id_rsa.pub` (public key)

However, you may also create a dedicated key pair for your cluster with:

```bash
ssh-keygen -f my-key
```

This creates two files named `my-key` (private key) and `my-key.pub` (public key).

You will have to provide the filenames of your selected key pair to the `private_key_file` and `public_key_file` variables of the module (which are the only required variables of the module).

## Created AWS resources

With the default values (1 master node + 2 worker nodes = 3 nodes total), the module results in the creation of the following AWS resources:

| Explicitly created        | Implicitly created (default sub-resources)                          |
|---------------------------|---------------------------------------------------------------------|
| 1 [VPC][vpc]              | 1 [Route Table][rtb], 1 [Security Group][sg], 1 [Network ACL][acl]  |
| 1 [Subnet][subnet]        |                                                                     |
| 1 [Internet Gateway][igw] |                                                                     |
| 1 [Route Table][rtb]      |                                                                     |
| 4 [Security Groups][sg]   |                                                                     |
| 1 [Key Pair][key]         |                                                                     |
| 1 [Elastic IP][eip]       |                                                                     |
| 3 [EC2 Instances][i]      | 3 [Volumes][vol], 3 [Network Interfaces][eni]                       |

[vpc]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html
[acl]: https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html
[rtb]: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html
[sg]: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html
[subnet]: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html
[igw]: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html
[eip]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html
[i]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html
[vol]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AmazonEBS.html
[eni]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html
[key]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html

**Total: 22 resources**

With each added or removed worker node, you can add or subtract 3 from the total number of resources, since each EC2 instance results in the creation of 3 resources (the instance itself, the volume, and the network interface).

For example:

- With 1 worker node (2 nodes total), the total number of resources is 19
- With 2 worker nodes (3 nodes total), the total number of resources is 22
- With 3 worker nodes (4 nodes total), the total number of resources is 25

You can list all resources that you have in a given region in the [Tag Editor](https://console.aws.amazon.com/resource-groups/tag-editor) of the AWS Console.

> Note that [Key Pairs][key] are not listed in the Tag Editor.
