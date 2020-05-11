# AWS network module

Terraform module for creating a VPC that can be used with the [kubeadm](https://github.com/weibeld/terraform-aws-kubeadm) module.

## Contents

- [**Description**](#description)
- [**Quick start**](#quick-start)
- [**AWS resources**](#aws-resources)

## Description

This module creates a VPC with a single subnet. This VPC and subnet can then be used by the [kubeadm](https://github.com/weibeld/terraform-aws-kubeadm) module as a dedicated network infrastructure for the created Kubernetes clusters.

## Quick start

A minimal usage of the module looks as follows:

```hcl
provider "aws" {
  region = "eu-central-1"
}

module "network" {
  source     = "weibeld/kubeadm/aws//modules/network"
  version    = "~> 0.2"
}
```

This creates a new VPC and subnet in the `eu-central-1` region.

The ID of the created VPC and subnet can then be passed to the `vpc_id` and `subnet_id` variables of the [kubeadm](https://github.com/weibeld/terraform-aws-kubeadm) module, which causes the Kubernetes cluster to be created in the given VPC and subnet.

For how to use the network submodule together with the kubeadm module, see the [_cluster in dedicated VPC_](https://github.com/weibeld/terraform-aws-kubeadm/tree/master/examples/ex3-cluster-in-dedicated-vpc) example.

## AWS resources

The module creates the following AWS resources:

| Explicitly created        | Implicitly created (default sub-resources)                          |
|---------------------------|---------------------------------------------------------------------|
| 1 [VPC][vpc]              | 1 [Route Table][rtb], 1 [Security Group][sg], 1 [Network ACL][acl]  |
| 1 [Subnet][subnet]        |                                                                     |
| 1 [Internet Gateway][igw] |                                                                     |
| 1 [Route Table][rtb]      |                                                                     |

**Total: 7 resources**

[vpc]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html
[acl]: https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html
[rtb]: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html
[sg]: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html
[subnet]: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html
[igw]: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html

You can list all AWS resources in a given region with the [Tag Editor](https://console.aws.amazon.com/resource-groups/tag-editor) in the AWS Console.
