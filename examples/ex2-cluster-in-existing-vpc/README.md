# Example: cluster in existing VPC

This example shows how to create a Kubernetes cluster in an existing VPC.

## Description

This example invokes the [kubeadm module](https://registry.terraform.io/modules/weibeld/kubeadm/aws) with the following optional variables:

- `vpc_id`
- `subnet_id`

The values for these variables are AWS resource IDs of an existing VPC and subnet. This causes the kubeadm module to create the resources for the cluster in the provided VPC and subnet.

The provided VPC and subnet may already contain other resources. The VPC also may contain additional subnets, but the cluster resources will be created only in the provided single subnet.

## VPC requirements

The VPC and subnet that you pass to the kubeadm module must satsify the following requirements:

- The VPC must have an [Internet Gateway](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html)
- The subnet must have a [Route Table](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html) with a route that routes non-local traffic to the Internet Gateway
- The subnet must be in the VPC
- The VPC and subnet must be in the same AWS region that is configured in the [`aws`](https://www.terraform.io/docs/providers/aws/index.html) provider block

## Creating a VPC

You can create a VPC that satisfies the requirements for the kubeadm module either with the [network submodule](https://github.com/weibeld/terraform-aws-kubeadm/tree/master/modules/network), or, for example, with the following [AWS CLI](https://aws.amazon.com/cli/) commands:

```bash
# Create VPC
vpc_id=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --query Vpc.VpcId --output text)

# Create internet gateway and attach it to the VPC
internet_gateway_id=$(aws ec2 create-internet-gateway --query InternetGateway.InternetGatewayId --output text)
aws ec2 attach-internet-gateway --internet-gateway-id "$internet_gateway_id" --vpc-id "$vpc_id"

# Create subnet
subnet_id=$(aws ec2 create-subnet --cidr-block 10.0.0.0/16 --vpc-id "$vpc_id" --query Subnet.SubnetId --output text)

# Create route table, add a route to the internet gateway, and associate it with the subnet
route_table_id=$(aws ec2 create-route-table --vpc-id "$vpc_id" --query RouteTable.RouteTableId --output text)
aws ec2 create-route --route-table-id "$route_table_id" --destination-cidr-block 0.0.0.0/0 --gateway-id "$internet_gateway_id"
aws ec2 associate-route-table --route-table-id "$route_table_id" --subnet-id "$subnet_id"
```

## Files

- [`main.tf`](https://github.com/weibeld/terraform-aws-kubeadm/blob/master/examples/ex2-cluster-in-existing-vpc/main.tf)
- [`variables.tf`](https://github.com/weibeld/terraform-aws-kubeadm/blob/master/examples/ex2-cluster-in-existing-vpc/variables.tf)
- [`outputs.tf`](https://github.com/weibeld/terraform-aws-kubeadm/blob/master/examples/ex2-cluster-in-existing-vpc/outputs.tf)
- [`terraform.tfvars`](https://github.com/weibeld/terraform-aws-kubeadm/blob/master/examples/ex2-cluster-in-existing-vpc/terraform.tfvars)
