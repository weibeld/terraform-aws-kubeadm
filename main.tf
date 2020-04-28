provider "aws" {
  # Credentials are read from ~/.aws/credentials
  region = var.region
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/16"
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "main" {
  route_table_id = aws_route_table.main.id
  subnet_id      = aws_subnet.main.id
}

resource "aws_security_group" "base" {
  name        = "base"
  description = "Allow all incoming traffic from same security group and all outgoing traffic"
  vpc_id      = aws_vpc.main.id
  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    self        = true
    description = "Allow all incoming traffic from same security group"
  }
  # The AWS provider removes the default egress rule, so it has to be redefined
  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outgoing traffic"
  }
}

resource "aws_security_group" "k8s" {
  name        = "k8s"
  description = "Allow incoming Kubernetes traffic (TCP/6443) from everywhere"
  vpc_id      = aws_vpc.main.id
  ingress {
    protocol    = "tcp"
    from_port   = 6443
    to_port     = 6443
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ssh" {
  name        = "ssh"
  description = "Allow incoming SSH traffic (TCP/22) from the local machine"
  vpc_id      = aws_vpc.main.id
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["${var.localhost_ip}/32"]
  }
}

data "local_file" "public_key" {
  filename = pathexpand(var.public_key_file)
}

# Performs 'ImportKeyPair' API operation (not 'CreateKeyPair')
resource "aws_key_pair" "main" {
  key_name_prefix = "example-infra-terraform-"
  public_key      = data.local_file.public_key.content
}

data "aws_ami" "ubuntu" {
  owners = ["099720109477"] # AWS account ID of Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
  most_recent = true
}

# TODO:
#   [ ] Generate token dynamically
#   [ ] Add extra SAN with public IP address of master node to API server certificate (probably requires using EIPs)
#   [ ] Download kubeconfig files to local machine

locals {
  install_kubeadm = <<-EOF
    apt-get update
    apt-get install -y apt-transport-https curl
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" >/etc/apt/sources.list.d/kubernetes.list
    apt-get update
    apt-get install -y docker.io kubeadm
    EOF
  token           = "zq7c0d.zc8dk1e8v0bj54c8"
}

resource "aws_instance" "master" {
  ami                         = data.aws_ami.ubuntu.image_id
  instance_type               = "t2.medium"
  subnet_id                   = aws_subnet.main.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.main.key_name
  vpc_security_group_ids = [
    aws_security_group.base.id,
    aws_security_group.k8s.id,
    aws_security_group.ssh.id
  ]
  user_data = <<-EOF
  #!/bin/bash
  ${local.install_kubeadm}
  kubeadm init --token ${local.token}
  EOF
}

resource "aws_instance" "workers" {
  count                       = 2
  ami                         = data.aws_ami.ubuntu.image_id
  instance_type               = "t2.small"
  subnet_id                   = aws_subnet.main.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.main.key_name
  vpc_security_group_ids = [
    aws_security_group.base.id,
    aws_security_group.ssh.id
  ]
  user_data = <<-EOF
  #!/bin/bash
  ${local.install_kubeadm}
  kubeadm join ${aws_instance.master.private_ip}:6443 --discovery-token-unsafe-skip-ca-verification --token ${local.token}
  EOF
}
