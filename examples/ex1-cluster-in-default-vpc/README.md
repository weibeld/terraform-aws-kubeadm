# Example: cluster in default VPC

This example shows how to create a cluster in the default VPC of a given AWS region.

## Description

The Terraform configuration for this example consists of the following files:


The `main.tf` file invokes the [kubeadm module](https://registry.terraform.io/modules/weibeld/kubeadm/aws) with only the required variables, which causes a cluster with default settings being created in the default VPC.

## Files

- [`main.tf`](https://github.com/weibeld/terraform-aws-kubeadm/blob/master/examples/ex1-cluster-in-default-vpc/main.tf)
- [`variables.tf`](https://github.com/weibeld/terraform-aws-kubeadm/blob/master/examples/ex1-cluster-in-default-vpc/variables.tf)
- [`outputs.tf`](https://github.com/weibeld/terraform-aws-kubeadm/blob/master/examples/ex1-cluster-in-default-vpc/outputs.tf)
- [`terraform.tfvars`](https://github.com/weibeld/terraform-aws-kubeadm/blob/master/examples/ex1-cluster-in-default-vpc/terraform.tfvars)
