# Example: multiple clusters

This example shows how to create multiple clusters in the same Terraform configuration

## Description

This example creates three Kubernetes clusters in the default VPC of the given AWS region.

The creation of multiple clusters is achieved by invoking the [kubeadm](https://github.com/weibeld/terraform-aws-kubeadm) module multiple times (in this case, three times).

Each invocation of the kubeadm module sets the `cluster_name` variable of the module to a value that can be provided by the user through the `cluster_names` variable. This allows giving custom names to the clusters (such as `alpha`, `beta`, and `gamma`). If the `cluster_names` variable is unset, then a random name is automatially chosen for each cluster.

The kubeconfig files for the individual clusters will be saved in the current working directory with a name corresponding to the cluster they belong to. For example, the kubeconfig file for the `alpha` cluster will be named `alpha.conf`.

## Usage with an existing or dedicated VPC

You can extend this example to use an existing or dedicated VPC by using the same principles as explained in the [_cluster in existing VPC_](https://github.com/weibeld/terraform-aws-kubeadm/tree/master/examples/ex2-cluster-in-existing-vpc) and [_cluster in dedicated VPC_](https://github.com/weibeld/terraform-aws-kubeadm/tree/master/examples/ex3-cluster-in-dedicated-vpc) examples.

In summary, you just need to set the `vpc_id` and `subnet_id` variables of the individual invocations of the kubeadm module to cause the creation of this cluster in the provided VPC and subnet.

## Files

- [`main.tf`](https://github.com/weibeld/terraform-aws-kubeadm/blob/master/examples/ex4-multiple-clusters/main.tf)
- [`variables.tf`](https://github.com/weibeld/terraform-aws-kubeadm/blob/master/examples/ex4-multiple-clusters/variables.tf)
- [`outputs.tf`](https://github.com/weibeld/terraform-aws-kubeadm/blob/master/examples/ex4-multiple-clusters/outputs.tf)
- [`terraform.tfvars`](https://github.com/weibeld/terraform-aws-kubeadm/blob/master/examples/ex4-multiple-clusters/terraform.tfvars)

## Note

At the moment (Terraform 0.12), [work seems to be underway for Terraform 0.13](https://github.com/hashicorp/terraform/issues/17519) to implement the `count` and `for_each` meta-arguments for modules. This feature will allow determining the number of times a module is invoked dynamically.

For this example, this means that the number of clusters to create could be dynamically determined by the user through a variable (rather than the number of clusters being hardcoded in the configuration, as its presently the case).

Thus, when this feature will be released, this example can be rewritten to use the `count` meta-argument when invoking the kubeadm module.
