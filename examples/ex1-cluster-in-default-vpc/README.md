# Example: cluster in default VPC

This example shows how to create a cluster in the default VPC of a given AWS region.

## Description

This example invokes the [kubeadm](https://github.com/weibeld/terraform-aws-kubeadm) module with only the required variables.

This results in a cluster with default parameters being created in the default VPC and subnet of the configured AWS region.

## Files

- [`main.tf`](https://github.com/weibeld/terraform-aws-kubeadm/blob/master/examples/ex1-cluster-in-default-vpc/main.tf)
- [`variables.tf`](https://github.com/weibeld/terraform-aws-kubeadm/blob/master/examples/ex1-cluster-in-default-vpc/variables.tf)
- [`outputs.tf`](https://github.com/weibeld/terraform-aws-kubeadm/blob/master/examples/ex1-cluster-in-default-vpc/outputs.tf)
- [`terraform.tfvars`](https://github.com/weibeld/terraform-aws-kubeadm/blob/master/examples/ex1-cluster-in-default-vpc/terraform.tfvars)
