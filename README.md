# AWS kubeadm module

Terraform module for bootstrapping a Kubernetes cluster with kubeadm on AWS.

## Description

This module allows to create AWS infrastructure and bootstrap a Kubernetes cluster on it with a single command.

The result of running the module is a freshly bootstrapped Kubernetes cluster — like what you get after manually running `kubeadm init` and `kubeadm join`.

The module also creates a kubeconfig file on your local machine so that you can access the cluster right away.

The number and types of nodes, the Pod network CIDR block, and many other parameters are configurable.

Notes:

- The module does not install any CNI plugin in the cluster, which reflects the behaviour of kubeadm
- For now, the created clusters are limited to a single master node

## Intended use

The module is intended to be used for experiments. It automates the process of bootstrapping a cluster, which allows you to create a series of clusters quickly and then run experiments on them.

The module does on purpose not produce production-ready cluster, for example, by installing a CNI plugin, because this might interfere with experiments that you want to run on the bootstrapped clusters.

In other words, since the module does not install a CNI plugin by default, you can use this module to test arbitrary configurations of CNI plugins on a freshly bootstrapped cluster.

## Quick start

First, ensure the [prerequisites](#prerequisites) below.

A minimal usage of the module looks as follows:

```hcl
provider "aws" {
  region = "eu-central-1"
}

module "cluster" {
  source           = "weibeld/kubeadm/aws"
  version          = "~> 0.1"
  private_key_file = "~/.ssh/id_rsa"
  public_key_file  = "~/.ssh/id_rsa.pub"
}
```

This results in the creation of a Kubernetes cluster with one master node and two worker nodes in the default VPC of the `eu-central-1` region.

The only required variables of the module are `privat_key_file` and `public_key_file` which must specify a key pair on your local machine that will allow you to SSH into the nodes of the cluster.

The cluster is given a random name (such as `relaxed-ocelot`) and the module creates a kubeconfig file on your local machine that is named after the cluster it belongs to (such as `relaxed-ocelot.conf`). By default, this kubeconfig file is created in your current working directory.

You can use this kubeconfig file to access the cluster. For example:

```bash
kubectl --kubeconfig relaxed-ocelot.conf get nodes -o wide
```

> Note that if you execute the above command, you will see that all nodes are `NotReady`. This is the expected behaviour because the cluster does not yet have a CNI plugin installed.

You may also set the [`KUBECONFIG`](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/#set-the-kubeconfig-environment-variable) environment variable so that you don't need to set the `--kubeconfig` flag for every kubectl command:

```bash
export KUBECONFIG=$(pwd)/relaxed-ocelot.conf
```

You can SSH into the nodes of your cluster as follows:

```bash
ssh -i ~/.ssh/id_rsa ubuntu@3.121.110.233
```

In the above example, `~/.ssh/id_rsa` is the private key that you specified to the `private_key_file` variable of the module, and `3.121.110.233` is the public IP address of the EC2 instance that corresponds to the desired cluster node.

For more details about the created AWS resources, see [AWS resources](#aws-resources) below. For more advanced usage examples, see the [examples](https://github.com/weibeld/terraform-aws-kubeadm/tree/master/examples).

## Prerequisites

The module depends on the following prerequisites:

### 1. Terraform is installed

The [Terraform documentation](https://www.terraform.io/downloads.html) includes instruction for installing Terraform on your target platform.

> On macOS, you can install Terraform with `brew install terraform`.

### 2. AWS credentials are configured

Terraform needs to have access to the **AWS Access Key ID** and **AWS Secret Access Key** of your AWS account in order to create AWS resources.

You can enable this in one of the two following ways:

-  Create an [`~/.aws/credentials`](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html#cli-configure-files-where) file. This is automatically done for you if you configure the [AWS CLI](https://aws.amazon.com/cli/):

    ```bash
    aws configure
    ```

- Set the [`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html) environment variables to your Access Key ID and Secret Access Key:

    ```bash
    export AWS_ACCESS_KEY_ID=<AccessKeyID>
    export AWS_SECRET_ACCESS_KEY=<SecretAccessKey>
    ```

### 3. Key pair on your local machine

The module requires you to specify a key pair which will allow you to SSH into the nodes of the cluster.

You can use any key pair on your local machine for this, for example, the default `~/.ssh/id_rsa` (private key) and `~/.ssh/id_rsa.pub` (public key).

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

Note that each node results in the creation of 3 AWS resources: 1 EC2 instance, 1 Volume, and 1 Network Interface. Consequently, you can add or subtract 3 from the total number of created AWS resources for each added or removed worker node. For example:

- 1 worker node: total 12 AWS resources
- 2 worker nodes: total 15 AWS resources
- 3 worker nodes: total 18 AWS resources

You can list all resources that you have in a given region with the [Tag Editor](https://console.aws.amazon.com/resource-groups/tag-editor) in the AWS Console.

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
