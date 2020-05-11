# Example: cluster in dedicated VPC

This example shows how to create a cluster in a dedicated VPC created with the [network submodule](https://github.com/weibeld/terraform-aw-kubeadm/tree/master/modules/network).

## Description

This example invokes both the [kubeadm module](https://github.com/weibeld/terraform-aws-kubeadm) and the [network submodule](https://github.com/weibeld/terraform-aws-kubeadm/tree/master/modules/network).

The network submodule creates a VPC and subnet and outputs the AWS resource IDs of this VPC and subnet.

The example then invokes the kubeadm module by passing the VPC and subnet ID from the network submodule output to the following input variables of the kubeadm module:

- `vpc_id`
- `subnet_id`

This causes the kubeadm module to create the cluster in the VPC and subnet that have just been created by the network submodule.

## Files

- [`main.tf`](https://github.com/weibeld/terraform-aws-kubeadm/blob/master/examples/ex3-cluster-in-dedicated-vpc/main.tf)
- [`variables.tf`](https://github.com/weibeld/terraform-aws-kubeadm/blob/master/examples/ex3-cluster-in-dedicated-vpc/variables.tf)
- [`outputs.tf`](https://github.com/weibeld/terraform-aws-kubeadm/blob/master/examples/ex3-cluster-in-dedicated-vpc/outputs.tf)
- [`terraform.tfvars`](https://github.com/weibeld/terraform-aws-kubeadm/blob/master/examples/ex3-cluster-in-dedicated-vpc/terraform.tfvars)
