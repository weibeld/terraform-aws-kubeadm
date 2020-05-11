# Example: cluster in default VPC

This example shows how to create a cluster in the default VPC of a given AWS region.

## Description

This example invokes the [kubeadm](https://github.com/weibeld/terraform-aws-kubeadm) module with all variables left at the default values.

The AWS region in which the cluster is created can be specified with the `region` variable.

This results in a cluster with a single master node and two worker nodes being created in one of the default subnets of the default VPC in the specified AWS region.

## Files

- [`main.tf`](https://github.com/weibeld/terraform-aws-kubeadm/blob/master/examples/ex1-cluster-in-default-vpc/main.tf)
- [`variables.tf`](https://github.com/weibeld/terraform-aws-kubeadm/blob/master/examples/ex1-cluster-in-default-vpc/variables.tf)
- [`outputs.tf`](https://github.com/weibeld/terraform-aws-kubeadm/blob/master/examples/ex1-cluster-in-default-vpc/outputs.tf)
- [`terraform.tfvars`](https://github.com/weibeld/terraform-aws-kubeadm/blob/master/examples/ex1-cluster-in-default-vpc/terraform.tfvars)
