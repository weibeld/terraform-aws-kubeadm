# AWS kubeadm module

Terraform module for bootstrapping a Kubernetes cluster with kubeadm on AWS.

## Contents

- [**Description**](#description)
- [**Intended usage**](#intended-usage)
- [**Quick start**](#quick-start)
- [**Prerequisites**](#prerequisites)
- [**AWS resources**](#aws-resources)
- [**Network submodule**](#network-submodule)

## Description

This module allows to create AWS infrastructure and bootstrap a Kubernetes cluster on it with a single command.

Running the module results in a freshly bootstrapped Kubernetes cluster — like what you get after manually bootstrapping a cluster with `kubeadm init` and `kubeadm join`.

The module also creates a kubeconfig file on your local machine so that you can access the cluster right away.

The number and types of nodes, the Pod network CIDR block, and many other parameters are configurable.

Notes:

- The module does not install any CNI plugin in the cluster, which reflects the behaviour of kubeadm
- For now, the created clusters are limited to a single master node

## Intended usage

The module is intended to be used for experiments. It automates the process of bootstrapping a cluster, which allows you to create a series of clusters quickly and then run experiments on them.

The module does on purpose not produce production-ready cluster, for example, by installing a CNI plugin, because this might interfere with experiments that you want to run on the bootstrapped clusters.

In other words, since the module does not install a CNI plugin by default, you can use this module to test arbitrary configurations of CNI plugins on a freshly bootstrapped cluster.

## Prerequisites

In order to use this module, make sure to meet the following prerequisites.

### Terraform

Install Terraform as described in the [Terraform documentation](https://learn.hashicorp.com/tutorials/terraform/install-cli).

If you use macOS, you can simply do:

```bash
brew install terraform
```

### AWS credentials

Install the AWS CLI as described in the [AWS CLI documentation](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html).

Once this is done, run the following command:

```bash
aws configure
```

And enter your **AWS Access Key ID** and **AWS Secret Access Key** in the interactive dialog. 

> You can find the AWS Access Key ID of your AWS user account on the [IAM page](https://console.aws.amazon.com/iamv2/home#/users) of the AWS Console. The AWS Secret Access Key is only displayed immediately after creating a new AWS user and you should keep it safe.

The above command saves your credentials in a file named [`~/.aws/credentials`](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html#cli-configure-files-where).

You can verify that the AWS credentials have been correctly configured with the following command:

```bash
aws sts get-caller-identity
```

The output should be something like:

```json
{
    "UserId": "XYZXYZXYZXYZXYZXYZXYZ",
    "Account": "123123123123",
    "Arn": "arn:aws:iam::123123123123:user/myusername"
}
```

Verify that the `Account` field matches the ID of your AWS account (which you can find on the [My Account](https://console.aws.amazon.com/billing/home?#/account) page in the AWS Console), and that the `Arn` field includes the name of your AWS user.

### OpenSSH

The module requires the `ssh` and `scp` commands, which are most probably already installed on your system. In case they aren't, you can install them with:

```bash
# Linux
sudo apt-get install openssh-client
# macOS
brew install openssh
```

The module, by default, uses the default SSH key par `~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub` to set up SSH acess to your cluster nodes. In case you don't have this key pair, you can create it with:

```bash
ssh-keygen
```

> Note that you can configure a different SSH key pair through the module's [input variables](variables.tf).

## Quick start

> The following demonstrates a minimal usage of the module using all the default values. This will create a Kubernetes cluster with a single master node and two worker nodes.

Create an empty directory and save the following configuration in a file named `main.tf`:

```hcl
provider "aws" {
  region = "eu-central-1"
}

module "cluster" {
  source           = "weibeld/kubeadm/aws"
  version          = "0.2.6"
}
```

> The `region` variable specifies the AWS region in which the cluster will be created. You can insert your desired [AWS region](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-available-regions) there.

Now, run the following command:

```bash
terraform init
```

The [`terraform init`](https://www.terraform.io/docs/cli/commands/init.html) command downloads the module as well as the latest versions of any required [providers](https://registry.terraform.io/browse/providers).

Next, run:

```bash
terraform apply
```

The [`terraform apply`](https://www.terraform.io/docs/cli/commands/apply.html) command first displays all the AWS resources that it's planning create, and asks you in an interactive dialog if you want to proceed.

Type `yes` to proceed.

> If you want to skip the interactive dialog and automatically proceed, you can use `terraform apply --auto-approve`.





### Cleaning up

To delete the Kubernetes cluster, run the following command:

```bash
terraform destroy
```

The [`terraform destroy`](https://www.terraform.io/docs/cli/commands/destroy.html) command first displays all the AWS resources it's planning to delete, and asks you for confirmation to proceed.

Type `yes` to proceed.

> Again, if you want to skip the interactive dialog and automatically proceed, you can use `--auto-approve` flag.

After a few minutes, all the AWS resources that you previously created should be deleted, and your AWS account should be in exactly the same state as before you created the Kubernetes cluster.




Running `terraform apply` with this configuration results in the creation of a Kubernetes cluster with one master node and two worker nodes in one of the default subnets of the default VPC of the `eu-central-1` region.

The cluster is given a random name (e.g. `relaxed-ocelot`) and the module creates a kubeconfig file on your local machine that is named after the cluster it belongs to (e.g. `relaxed-ocelot.conf`). By default, this kubeconfig file is created in your current working directory.

You can use this kubeconfig file to access the cluster. For example:

```bash
kubectl --kubeconfig relaxed-ocelot.conf get nodes
```

> Note that if you execute the above command, you will see that all nodes are `NotReady`. This is the expected behaviour because the cluster does not yet have a CNI plugin installed.

You may also set the [`KUBECONFIG`](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/#set-the-kubeconfig-environment-variable) environment variable so that you don't need to set the `--kubeconfig` flag for every kubectl command:

```bash
export KUBECONFIG=$(pwd)/relaxed-ocelot.conf
```

> Note that when you delete the cluster with `terraform destroy`, the kubeconfig file is currently not automatically deleted, thus you have to clean it up yourself if you don't want to have it sticking around.

The module also sets up SSH access to the nodes of the cluster. By default, it uses the OpenSSH default key pair consisting of `~/.ssh/id_rsa` (private key) and `~/.ssh/id_rsa.pub` (public key) on your local machine for this. Thus, you can connect to the nodes of the cluster as follows:

```bash
ssh -i ~/.ssh/id_rsa ubuntu@<PUBLIC-IP>
```

The public IP addresses of all the nodes are specified in the output of the module, which you can display with `terraform output`.

For details about the created AWS resources, see [AWS resources](#aws-resources) below. For more advanced usage examples, see the [examples](https://github.com/weibeld/terraform-aws-kubeadm/tree/master/examples).

## Prerequisites

The module depends on the following prerequisites:


## AWS resources

With the default settings (1 master node and 2 worker nodes), the module creates the following AWS resources:

| Explicitly created        | Implicitly created (default sub-resources)                          |
|---------------------------|---------------------------------------------------------------------|
| 4 [Security Groups][sg]   |                                                                     |
| 1 [Key Pair][key]         |                                                                     |
| 1 [Elastic IP][eip]       |                                                                     |
| 3 [EC2 Instances][i]      | 3 [Volumes][vol], 3 [Network Interfaces][eni]                       |

**Total: 15 resources**

[sg]: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html
[eip]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html
[i]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html
[vol]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AmazonEBS.html
[eni]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html
[key]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html

Note that each node results in the creation of 3 AWS resources: 1 EC2 instance, 1 Volume, and 1 Network Interface. Consequently, you can add or subtract 3 from the total number of created AWS resources for each added or removed worker node. For example:

- 1 worker node: total 12 AWS resources
- 2 worker nodes: total 15 AWS resources
- 3 worker nodes: total 18 AWS resources

You can list all AWS resources in a given region with the [Tag Editor](https://console.aws.amazon.com/resource-groups/tag-editor) in the AWS Console.

> Note that [Key Pairs][key] are not listed in the Tag Editor.

### Tags

The module assigns a tag with a key of `kubeadm:cluster` and a value corresponding to the cluster name to all explicitly created resources. For example, if the cluster name is `relaxed-ocelot`, all of the above explicitly created resources will have the following tag:

```
kubeadm:cluster=relaxed-ocelot
```

This allows you to easily identify the resources that belong to a given cluster.

> Note that the implicitly created sub-resources (such as the Volumes and Network Interfaces of the EC2 Instances) won't have the `kubeadm:cluster` tag assigned.

Additionally, the EC2 instances will get a tag with a key of `kubeadm:node` and a value corresponding to the Kubernetes node name. For the master node, this is:

```
kubeadm:node=master
```

And for the worker nodes:

```
kubeadm:node=worker-X
```

Where `X` is an index starting at 0.

## Network submodule

By default, the kubeadm module creates the cluster in the [default VPC](https://docs.aws.amazon.com/vpc/latest/userguide/default-vpc.html) of the specified AWS region.

The [network submodule](https://github.com/weibeld/terraform-aws-kubeadm/tree/master/modules/network) allows you to create a dedicated VPC for your cluster.

See the [_cluster in dedicated VPC_](https://github.com/weibeld/terraform-aws-kubeadm/tree/master/examples/ex3-cluster-in-dedicated-vpc) example for how to use the network submodule together with the kubeadm module.
