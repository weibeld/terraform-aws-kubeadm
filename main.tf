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
#   [X] Generate token dynamically
#   [X] Add extra SAN with public IP address of master node to API server certificate (probably requires using EIPs)
#   [X] Download kubeconfig file to local machine
#   [X] Reduce TTL of bootstrap token

resource "random_string" "token_id" {
  length  = 6
  special = false
  upper   = false
}

resource "random_string" "token_secret" {
  length  = 16
  special = false
  upper   = false
}

locals {
  install_kubeadm = <<-EOF
    apt-get update
    apt-get install -y apt-transport-https curl
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" >/etc/apt/sources.list.d/kubernetes.list
    apt-get update
    apt-get install -y docker.io kubeadm
    EOF
  token           = "${random_string.token_id.result}.${random_string.token_secret.result}"
}

# EIP for master node because it must know its public IP during initialisation
resource "aws_eip" "master" {
  vpc        = true
  depends_on = [aws_internet_gateway.main]
}

resource "aws_eip_association" "master" {
  allocation_id = aws_eip.master.id
  instance_id   = aws_instance.master.id
}

resource "aws_instance" "master" {
  ami           = data.aws_ami.ubuntu.image_id
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.main.id
  key_name      = aws_key_pair.main.key_name
  vpc_security_group_ids = [
    aws_security_group.base.id,
    aws_security_group.ssh.id,
    aws_security_group.k8s.id
  ]
  user_data = <<-EOF
  #!/bin/bash
  ${local.install_kubeadm}
  kubeadm init \
    --token ${local.token} \
    --token-ttl 20m \
    --apiserver-cert-extra-sans ${aws_eip.master.public_ip}
  cp /etc/kubernetes/admin.conf /home/ubuntu
  chown ubuntu:ubuntu /home/ubuntu/admin.conf
  kubectl --kubeconfig /home/ubuntu/admin.conf config set-cluster kubernetes --server https://${aws_eip.master.public_ip}:6443
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
  kubeadm join ${aws_instance.master.private_ip}:6443 \
    --discovery-token-unsafe-skip-ca-verification \
    --token ${local.token}
  EOF
}

locals {
  kubeconfig = "kubeconfig"
}

# Wait for bootstrap to finish and download kubeconfig file
resource "null_resource" "wait" {
  provisioner "local-exec" {
    command = "while ! scp -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${var.private_key_file} ubuntu@${aws_eip.master.public_ip}:admin.conf ${local.kubeconfig} &>/dev/null; do sleep 1; done"
  }
  triggers = {
    instance_ids = join(",", concat([aws_instance.master.id], aws_instance.workers[*].id))
  }
}
