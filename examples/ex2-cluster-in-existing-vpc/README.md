# Example: cluster in existing VPC

This example shows how to create a cluster in an existing VPC.

## Description

The example invokes the [kubeadm](https://github.com/weibeld/terraform-aws-kubeadm) module with the following optional variables:

- `vpc_id`
- `subnet_id`

The values for these variables must be the IDs of an existing VPC and subnet, respectively. This causes the kubeadm module to create the cluster in the provided VPC and subnet.

The provided VPC and subnet may already contain other resources. The VPC also may contain additional subnets, but the cluster will be created exclusively in the provided subnet.

## VPC requirements

The VPC and subnet that you pass to the kubeadm module must satisfy the following requirements:

- The VPC must have an [Internet Gateway](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html)
- The subnet must have a [Route Table](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html) with a route that routes non-local traffic to the Internet Gateway
- The subnet must be in the VPC
- The VPC and subnet must be in the AWS region that is provided with the `region` variable

## Creating a VPC

You can use any existing VPC that satisfies the above requirements for this example.

If you want to create a new VPC, you can do so in several ways:

- Use the [network submodule](https://github.com/weibeld/terraform-aws-kubeadm/tree/master/modules/network) in this repository to create a suitable VPC with Terraform (see the [_cluster in dedicated VPC_](https://github.com/weibeld/terraform-aws-kubeadm/tree/master/examples/ex3-cluster-in-dedicated-vpc) example)
- Create a VPC with the following [AWS CLI](https://aws.amazon.com/cli/) commands:

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
