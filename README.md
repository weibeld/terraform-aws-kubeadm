# Bootstrap a Kubernetes cluster with Terraform on AWS

Terraform configuration for bootstrapping a Kubernetes cluster with kubeadm on AWS.

The cluster consists of a single master node and two worker nodes. No CNI plugin is installed.

## Prerequisites

- [Install Terraform](https://www.terraform.io/downloads.html):
    ```bash
    brew install terraform
    ```
- Install and configure the [`aws`](https://aws.amazon.com/cli/) CLI client for AWS
  - [Installation instructions](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
- Create a private/public key pair for the cluster nodes:
    ```bash
    ssh-keygen -f key
    ```

## Usage

### Define Terraform variables

Create a file named `terraform.tfvars` that defines values for the required Terraform variables:

```
localhost_ip     = "<LOCALHOST_IP>"
private_key_file = "<PRIVATE_KEY_FILE>"
public_key_file  = "<PUBLIC_KEY_FILE>"
```

Where:

- `<LOCALHOST_IP>` is the public IP address of your local machine, which you can find out with `curl checkip.amazonaws.com`.
- `<PRIVATE_KEY_FILE>` is the private key file that you created previously (e.g. `key`)
- `<PUBLIC_KEY_FILE>` is the public key file that you created previously (e.g. `key.pub`)

> You can see all variables that you can set in the `terraform.tfvars` file in [`variables.tf`](variables.tf). The variables without a default value are required, and the variables with a default value are optional.

### Create the cluster

```bash
terraform apply
```

The above command creates AWS infrastructure and bootstraps a Kubernetes cluster with kubeadm.

After a few minutes, the command should complete and you should have a file named `kubeconfig` in your current working directory. This is the kubeconfig file with which you will be able to access your cluster in the next step.

### Access the cluster

You can access the cluster with the kubeconfig file created by the above command:

```bash
kubectl --kubeconfig kubeconfig get nodes
```

> If you don't see all nodes yet, the cluster may still be bootstrapping. Just wait some few seconds and try again.

At this point, you can install a CNI plugin in your cluster. For example:

```bash
kubectl --kubeconfig kubeconfig apply -f https://raw.githubusercontent.com/cilium/cilium/1.7.0/install/kubernetes/quick-install.yaml
```

> You can set the `KUBECONFIG` environment variable to `$(pwd)/kubeconfig` so that you don't need to pass the `--kubeconfig` flag to every command.

## Destroy the cluster

```bash
terraform destroy
```

This command deletes the cluster and the entire AWS infrastructure that was created for it.
