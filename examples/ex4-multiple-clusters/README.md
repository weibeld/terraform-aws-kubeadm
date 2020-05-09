# Multiple clusters example

This example shows how to create multiple Kubernetes clusters with the [kubeadm](https://registry.terraform.io/modules/weibeld/kubeadm/aws) module.

## Description

The Terraform configuration of this example consists of the three usual files:

- [`main.tf`](https://github.com/weibeld/terraform-aws-kubeadm/blob/master/examples/multiple-clusters/main.tf)
- [`variables.tf`](https://github.com/weibeld/terraform-aws-kubeadm/blob/master/examples/multiple-clusters/variables.tf)
- [`outputs.tf`](https://github.com/weibeld/terraform-aws-kubeadm/blob/master/examples/multiple-clusters/outputs.tf)

The `main.tf` file defines three instances of the kubeadm module, which define three Kubernetes clusters with two worker nodes each. All clusters use the same key pair for their nodes, and each cluster is given an individual name.

The `variables.tf` file defines the input variables for the configuration. The only required variables are `private_key_file` and `public_key_file` which define a local key pair that can be used to SSH into the nodes of the cluster. The optional variables allow setting a name for each of the three clusters (`cluster_X_name`) and defining the AWS region in which to create the clusters (`region`).

The `outputs.tf` file defines the outputs of the Terraform configuration. This includes the location of the kubeconfig file for each cluster (`kubeconfigs`) and the details about the nodes of each cluster, such as their public and private IP addresses (`clusters`).

## Creating the infrastructure

First make sure that you have fulfilled the [prerequisites](https://github.com/weibeld/terraform-aws-kubeadm#prerequisites) for the kubeadm module.

Create a [`terraform.tfvars`](https://github.com/weibeld/terraform-aws-kubeadm/blob/master/examples/multiple-clusters/terraform.tfvars) file with your desired values for the input variables. For example:

```
private_key_file = "~/.ssh/id_rsa"
public_key_file  = "~/.ssh/id_rsa.pub"
cluster_1_name   = "alpha"
cluster_2_name   = "beta"
cluster_3_name   = "gamma"
```

Initialise Terraform:

```bash
terraform init
```

Create the infrastructure:

```bash
terraform apply
```


## Using the infrastructure

At the end of its execution, the `terraform apply` command prints an output of the following form (truncated):

```
clusters = {
  "alpha" = [
    {
      "name" = "master"
      "private_ip" = "172.16.209.40"
      "public_ip" = "52.29.4.111"
    },
    {
      "name" = "worker-0"
      "private_ip" = "172.16.201.54"
      "public_ip" = "3.123.254.114"
    },
    {
      "name" = "worker-1"
      "private_ip" = "172.16.54.176"
      "public_ip" = "18.196.31.247"
    },
  ]
  "beta" = [ /* ... */ ]
  "gamma" = [ /* ... */ ]
}
kubeconfigs = {
  "alpha" = "/Users/dw/terraform-aws-kubeadm/examples/multiple-clusters/alpha.conf"
  "beta" = "/Users/dw/terraform-aws-kubeadm/examples/multiple-clusters/beta.conf"
  "gamma" = "/Users/dw/terraform-aws-kubeadm/examples/multiple-clusters/gamma.conf"
}
```

> You can print this output any time with `terraform output`.

The `kubeconfigs` output contains the absolute path of the kubeconfig file of each cluster. The kubeconfig files are located in your current working directory and they are named after the name of each cluster.

You can use these kubeconfig files to access your newly created clusters.

For example, for accessing the `alpha` cluster:

```bash
kubectl --kubeconfig alpha.conf get nodes
```

The `clusters` output contains the names and public and private IP addresses of all the nodes of each cluster. You can SSH into any node of a cluster by using its public IP address and the private key file that you specified for the `private_key_file` variable.

For example, given the above example variables and output, you can connect to the `master` node of the `alpha` cluster as follows:

```bash
ssh -i ~/.ssh/id_rsa ubuntu@52.29.4.111
```

## Destroying the infrastructure

To delete all the AWS resources created by this Terraform configuration, use:

```bash
terraform destroy
```

Note that the created kubeconfig files on your local machine are not deleted by running `terraform destroy`, so you should clean them up manually.
