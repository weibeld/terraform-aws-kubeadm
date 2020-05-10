# Example: multiple clusters

This example shows how to create multiple clusters at once.

## Description

This example creates three Kubernetes clusters in the default VPC of the given AWS region.

The configuration invokes the [kubeadm](https://github.com/weibeld/terraform-aws-kubeadm) module three times which results in three clusters being created.

The example allows to optionally specify a custom name for each cluster (such as `["alpha", "beta", "gamma"]`). If this is omitted, a random name is chosen for each cluster.

The kubeconfig file of each created cluster is named after the cluster it belongs to. For example, the kubeconfig file of the `alpha` cluster will be named `alpha.conf`.

## Usage with an existing or dedicated VPC

You can extend this example to use an existing or dedicated VPC by following the same principles as explained in the [_cluster in existing VPC_](https://github.com/weibeld/terraform-aws-kubeadm/tree/master/examples/ex2-cluster-in-existing-vpc) and [_cluster in dedicated VPC_](https://github.com/weibeld/terraform-aws-kubeadm/tree/master/examples/ex3-cluster-in-dedicated-vpc) examples.

In essence, you just need to set the `vpc_id` and `subnet_id` variables in each invocation of the kubeadm module to appropriate values to cause the cluster to be created in the specified VPC and subnet.

## Files

- [`main.tf`](https://github.com/weibeld/terraform-aws-kubeadm/blob/master/examples/ex4-multiple-clusters/main.tf)
- [`variables.tf`](https://github.com/weibeld/terraform-aws-kubeadm/blob/master/examples/ex4-multiple-clusters/variables.tf)
- [`outputs.tf`](https://github.com/weibeld/terraform-aws-kubeadm/blob/master/examples/ex4-multiple-clusters/outputs.tf)
- [`terraform.tfvars`](https://github.com/weibeld/terraform-aws-kubeadm/blob/master/examples/ex4-multiple-clusters/terraform.tfvars)

## Note

At the moment (Terraform 0.12), [work seems to be underway](https://github.com/hashicorp/terraform/issues/17519) to implement the `count` and `for_each` meta-arguments for modules in Terraform 0.13. This feature will allow determining the number of times a module is invoked dynamically.

For this example, this means that the number of clusters to create could be dynamically determined by the user through a variable (rather than the number of clusters being hardcoded in the configuration, as its presently the case).

Thus, when this feature will be released, this example can be rewritten to use the `count` meta-argument in the module invocation.
