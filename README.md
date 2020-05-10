# AWS kubeadm module

Terraform module for bootstrapping a Kubernetes cluster with kubeadm on AWS.

## Description

This module allows to create AWS infrastructure and bootstrap a Kubernetes cluster on it with a single command.

The result of running the module is a freshly bootstrapped Kubernetes cluster like you get it after manually running `kubeadm init` and `kubeadm join`.

> The cluster will have no CNI plugin installed just as it's the case when manually bootstrapping a cluster with kubeadm.

The module also creates a kubeconfig file on your local machine so that you can access the cluster right away.

The number and type of nodes, the Pod network CIDR block, and many other parameters are configurable.

> For now, the cluster is limited to a single master node.

The intended use of the module is for experiments. The module allows you to quickly create a bare-bones cluster that you can then continue working on.

An example use case is testing CNI plugins which is made possible by the fact that the cluster won't have any CNI plugin installed by default.

## Quick usage

First, ensure the [prerequisites](#prerequisites) below.

A minimal example usage of the module in your Terraform configuration looks as follows:

```hcl
provider "aws" {
  region = "eu-central-1"
}

module "cluster" {
  source           = "weibeld/kubeadm/aws"
  version          = "~> 0.0"
  private_key_file = "~/.ssh/id_rsa"
  public_key_file  = "~/.ssh/id_rsa.pub"
}
```

This creates a Kubernetes cluster with 1 master node and 2 worker nodes in your default VPC in the `eu-central-1` region.

The only required variables of the module are `privat_key_file` and `public_key_file` which specify a local key pair that will allow you to SSH into the nodes of the cluster.

The cluster is given a random name (such as `relaxed-ocelot`) and when the `terraform apply` command completes, you will have a kubeconfig file named after the cluster (such as `relaxed-ocelot.conf`) in your current working directory.

You can use this kubeconfig file to access the newly created cluster:

```bash
kubectl --kubeconfig relaxed-ocelot.conf get nodes -o wide
```

> If you execute the above command, you will see that all nodes are `NotReady`. This is because your cluster does not yet have a CNI plugin installed and is the expected behaviour.

You may also set the [`KUBECONFIG`](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/#set-the-kubeconfig-environment-variable) environment variable so that you don't need to set the `--kubeconfig` flag for every command:

```bash
export KUBECONFIG=$(pwd)/relaxed-ocelot.conf
```

You can SSH into any node of your cluster as follows:

```bash
ssh -i ~/.ssh/id_rsa ubuntu@3.121.110.233
```

In the above example, `~/.ssh/id_rsa` is the private key that you specified to the `private_key_file` variable of the module, and `3.121.110.233` is the public IP address of the EC2 instance corresponding to the desired node.

For more details about the created AWS resources, see [AWS resources](#aws-resources) below. For more advanced usage examples, see the [examples](examples) directory.

## Prerequisites

The module depends on the following prerequisites:

### 1. Terraform is installed

The [Terraform documentation](https://www.terraform.io/downloads.html) includes instruction for installing Terraform on your target platform.

> On macOS, you can install Terraform with `brew install terraform`.

### 2. AWS credentials are configured

Terraform needs to have access to the **AWS Access Key ID** and **AWS Secret Access Key** of your AWS account in order to create resources.

You can enable this in one of the two following ways:

1. Create an [`~/.aws/credentials`](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html#cli-configure-files-where) file. This is automatically done for you if you configure the [AWS CLI](https://aws.amazon.com/cli/):
    ```bash
    aws configure
    ```
2. Directly the [`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html) environment variables to your Access Key ID and Secret Access Key:
    ```bash
    export AWS_ACCESS_KEY_ID=<AccessKeyID>
    export AWS_SECRET_ACCESS_KEY=<SecretAccessKey>
    ```

### 3. You have a key pair on your local machine

The module requires you to specify a key pair on your local machine that will allow you to SSH into the nodes of the cluster.

You can use any local key pair for this, for example, the default `~/.ssh/id_rsa` (private key) and `~/.ssh/id_rsa.pub` (public key).

You can also create a new key pair with:

```bash
ssh-keygen -f key
```

This creates two files named `key` (private key) and `key.pub` (public key).

> The public key file must be in the [OpenSSH format](https://blog.oddbit.com/post/2011-05-08-converting-openssh-public-keys/) which is the de-facto standard.

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

Note that each node results in the creation of 3 AWS resources: 1 EC2 instance, 1 Volume, and 1 Network Interface. Consequently, you can add or subtract 3 from the total number of created AWS resources for each added or removed worker node.

For example:

- 1 worker node: total 12 AWS resources
- 2 worker nodes: total 15 AWS resources
- 3 worker nodes: total 18 AWS resources

You can list all resources that you have in a given region with the [Tag Editor](https://console.aws.amazon.com/resource-groups/tag-editor) in the AWS Console.

> Note that [Key Pairs][key] are not listed in the Tag Editor.

The module assigns a tag with a key of `kubeadm:cluster` and a value corresponding to the cluster name to all explicitly created resources. For example, if the cluster name is `relaxed-ocelot`, all of the above explicitly created resources will have the following tag:

```
kubeadm:cluster=relaxed-ocelot
```

This allows you to easily identify the resources that belong to a given cluster.

> Note that the implicitly created sub-resources (such as the Volumes and Network Interfaces of the EC2 Instances) won't have the `kubeadm:cluster` tag assigned.

## Network submodule

By default, the kubeadm module creates the cluster in the [default VPC](https://docs.aws.amazon.com/vpc/latest/userguide/default-vpc.html) of the specified AWS region.

This repository also contains a [network submodule](modules/network), which allows to create a dedicated VPC in which to run one or multiple Kubernetes clusters.

For using the network submodule together with the kubeadm module, see the [examples](#examples/ex3-cluster-in-dedicated-vpc).
