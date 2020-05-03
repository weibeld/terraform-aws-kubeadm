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

> You can skip the manual approval of the command with `terraform apply --auto-approve`.

### Access the cluster

You can access the cluster with the kubeconfig file created by the above command:

```bash
kubectl --kubeconfig kubeconfig get nodes
```

At this point, you can install a CNI plugin in your cluster. For example:

```bash
kubectl --kubeconfig kubeconfig apply -f https://raw.githubusercontent.com/cilium/cilium/1.7.0/install/kubernetes/quick-install.yaml
```

> Instead of supplying the `--kubeconfig` flag for every command, you can do `export KUBECONFIG=$(pwd)/kubeconfig` to set your kubeconfig file as the default.

## Destroy the cluster

```bash
terraform destroy
```

This command deletes the cluster and the entire AWS infrastructure that was created for it.

> You can skip the manual approval of the command with `terraform destroy --auto-approve`.

## AWS resources

With the default values (1 master node + 2 worker nodes = 3 nodes total), the module results in the creation of the following AWS resources:

| Explicitly created        | Implicitly created (default sub-resources)                          |
|---------------------------|---------------------------------------------------------------------|
| 1 [VPC][vpc]              | 1 [Route Table][rtb], 1 [Security Group][sg], 1 [Network ACL][acl]  |
| 1 [Subnet][subnet]        |                                                                     |
| 1 [Internet Gateway][igw] |                                                                     |
| 1 [Route Table][rtb]      |                                                                     |
| 4 [Security Groups][sg]   |                                                                     |
| 1 [Key Pair][key]         |                                                                     |
| 1 [Elastic IP][eip]       |                                                                     |
| 3 [EC2 Instances][i]      | 3 [Volumes][vol], 3 [Network Interfaces][eni]                       |

[vpc]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html
[acl]: https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html
[rtb]: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html
[sg]: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html
[subnet]: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html
[igw]: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html
[eip]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html
[i]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html
[vol]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AmazonEBS.html
[eni]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html
[key]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html

**Total: 22 resources**

With each added or removed worker node, you can add or subtract 3 from the total number of resources, since each EC2 instance results in the creation of 3 resources (the instance itself, the volume, and the network interface).

For example:

- With 1 worker node (2 nodes total), the total number of resources is 19
- With 2 worker nodes (3 nodes total), the total number of resources is 22
- With 3 worker nodes (4 nodes total), the total number of resources is 25

You can list all resources that you have in a given region in the [Tag Editor](https://console.aws.amazon.com/resource-groups/tag-editor) of the AWS Console.

> Note that [Key Pairs][key] are not listed in the Tag Editor.
