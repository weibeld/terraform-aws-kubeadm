# AWS network module

Terraform module for creating VPC infrastructure that can be used with the [kubeadm](https://github.com/weibeld/terraform-aws-kubeadm) module.

## Description

This module creates a VPC with a single subnet and Internet access which can be used to host one or multiple Kubernetes clusters created with the [kubeadm](https://github.com/weibeld/terraform-aws-kubeadm) module.

## Quick usage

A minimal usage of the module is as follows:

```hcl
provider "aws" {
  region = "eu-central-1"
}

module "network" {
  source     = "weibeld/kubeadm/aws//modules/network"
  version    = "~> 0.0"
}
```

This creates a new VPC infrastructure in the `eu-central-1` region.

> For the detailed set o created AWS resources, see [AWS resources](#aws-resources) below.

The ID of the created VPC and subnet can then be passed to the corresponding input variables of the [kubeadm](https://github.com/weibeld/terraform-aws-kubeadm) module, which causes the Kubernetes cluster to be created in the given VPC.

For a more detailed usage example, see the [examples](#examples/ex3-cluster-in-dedicated-vpc).

### AWS resources

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

You can list all resources that you have in a given region with the [Tag Editor](https://console.aws.amazon.com/resource-groups/tag-editor) in the AWS Console.
