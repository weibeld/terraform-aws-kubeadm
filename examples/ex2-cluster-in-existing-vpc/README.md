# Example: creating a cluster in an existing VPC

## Example of creating a network infrastructure

Here is how you could create a suitable network infrastructure for usage with the kubeadm module:

```bash
{
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
}
```
