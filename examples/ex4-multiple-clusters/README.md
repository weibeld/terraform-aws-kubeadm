# Example: multiple clusters

This example shows how to create multiple Kubernetes clusters in the same Terraform configuration.

## Files

- [`main.tf`](https://github.com/weibeld/terraform-aws-kubeadm/blob/master/examples/ex4-multiple-clusters/main.tf)
- [`variables.tf`](https://github.com/weibeld/terraform-aws-kubeadm/blob/master/examples/ex4-multiple-clusters/variables.tf)
- [`outputs.tf`](https://github.com/weibeld/terraform-aws-kubeadm/blob/master/examples/ex4-multiple-clusters/outputs.tf)
- [`terraform.tfvars`](https://github.com/weibeld/terraform-aws-kubeadm/blob/master/examples/ex4-multiple-clusters/terraform.tfvars)

## Description

This example creates three Kubernetes clusters in the default VPC of a given AWS region.

The [kubeadm module](https://github.com/weibeld/terraform-aws-kubeadm) is invoked three times, which results in three clusters being created.

The configuation allows to optionally specify a custom name for each cluster (such as `alpha`, `beta`, and `gamma`). If this is not specified, a random name is chosen for each cluster.

For each cluster, a kubeconfig will be added to the current working directory. The kubeconfig files are named after the cluster they belong to. For example, the kubeconfig file for the `alpha` cluster is named `alpha.conf`.

## Usage with existing and dedicated VPC

You can create multiple clusters in an existing or dedicated VPC as explained in the [_cluster in existing VPC_](https://github.com/weibeld/terraform-aws-kubeadm/tree/master/examples/ex2-cluster-in-existing-vpc) and [_cluster in dedicated VPC_](https://github.com/weibeld/terraform-aws-kubeadm/tree/master/examples/ex3-cluster-in-dedicated-vpc) examples.

To do so, just set the `vpc_id` and `subnet_id` variables in each invocation of the kubeadm module.

## Note

In Terraform 0.12, modules do not yet support the `count` and `for_each` arguments, which would allow to dynamically determine the number of times a module is invoked. However, this feature seems to be [planned for Terraform 0.13](https://github.com/hashicorp/terraform/issues/17519).

When this feature is added, this example can be rewritten, which will allow the user to dynamically specify the number of clusters to create, rather than this being hardcoded in the configuration.
