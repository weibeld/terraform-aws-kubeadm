terraform {
  required_version = ">= 0.12"
}

#------------------------------------------------------------------------------#
# Common local values
#------------------------------------------------------------------------------#

resource "random_pet" "cluster_name" {}

locals {
  cluster_name = var.cluster_name != null ? var.cluster_name : random_pet.cluster_name.id
  tags         = merge(var.tags, { "kubeadm:cluster" = local.cluster_name })
}

#------------------------------------------------------------------------------#
# Key pair
#------------------------------------------------------------------------------#

# Creates a key pair
resource "tls_private_key" "ssh_server" {
  # This resource is not recommended for production environements
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Performs 'ImportKeyPair' API operation (not 'CreateKeyPair')
resource "aws_key_pair" "main" {
  key_name_prefix = "${local.cluster_name}-"
  public_key      = var.public_key_file != null ? file(var.public_key_file) : tls_private_key.ssh_server.public_key_openssh
  tags            = local.tags
}

#------------------------------------------------------------------------------#
# Security groups
#------------------------------------------------------------------------------#

# The AWS provider removes the default "allow all "egress rule from all security
# groups, so it has to be defined explicitly.
resource "aws_security_group" "egress" {
  name        = "${local.cluster_name}-egress"
  description = "Allow all outgoing traffic to everywhere"
  vpc_id      = var.vpc_id
  tags        = local.tags
  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ingress_internal" {
  name        = "${local.cluster_name}-ingress-internal"
  description = "Allow all incoming traffic from nodes and Pods in the cluster"
  vpc_id      = var.vpc_id
  tags        = local.tags
  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    self        = true
    description = "Allow incoming traffic from cluster nodes"

  }
  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = var.pod_network_cidr_block != null ? [var.pod_network_cidr_block] : null
    description = "Allow incoming traffic from the Pods of the cluster"
  }
}

resource "aws_security_group" "ingress_k8s" {
  name        = "${local.cluster_name}-ingress-k8s"
  description = "Allow incoming Kubernetes API requests (TCP/6443) from outside the cluster"
  vpc_id      = var.vpc_id
  tags        = local.tags
  ingress {
    protocol    = "tcp"
    from_port   = 6443
    to_port     = 6443
    cidr_blocks = var.allowed_k8s_cidr_blocks
  }
}

resource "aws_security_group" "ingress_ssh" {
  name        = "${local.cluster_name}-ingress-ssh"
  description = "Allow incoming SSH traffic (TCP/22) from outside the cluster"
  vpc_id      = var.vpc_id
  tags        = local.tags
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = var.allowed_ssh_cidr_blocks
  }
}

#------------------------------------------------------------------------------#
# Elastic IP for master node
#------------------------------------------------------------------------------#

# EIP for master node because it must know its public IP during initialisation
resource "aws_eip" "master" {
  vpc  = true
  tags = local.tags
}

resource "aws_eip_association" "master" {
  allocation_id = aws_eip.master.id
  instance_id   = aws_instance.master.id
}

#------------------------------------------------------------------------------#
# Bootstrap token for kubeadm
#------------------------------------------------------------------------------#

# Generate bootstrap token
# See https://kubernetes.io/docs/reference/access-authn-authz/bootstrap-tokens/
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
  token = "${random_string.token_id.result}.${random_string.token_secret.result}"
}

#------------------------------------------------------------------------------#
# EC2 instances
#------------------------------------------------------------------------------#

data "aws_ami" "ubuntu" {
  owners      = ["099720109477"] # AWS account ID of Canonical
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

resource "aws_instance" "master" {
  ami           = data.aws_ami.ubuntu.image_id
  instance_type = var.master_instance_type
  subnet_id     = var.subnet_id
  key_name      = aws_key_pair.main.key_name
  vpc_security_group_ids = [
    aws_security_group.egress.id,
    aws_security_group.ingress_internal.id,
    aws_security_group.ingress_k8s.id,
    aws_security_group.ingress_ssh.id
  ]
  tags      = merge(local.tags, { "kubeadm:node" = "master" })
  user_data = <<-EOF
  #!/bin/bash -xe

  # Install kubeadm and Docker
  apt-get update
  apt-get install -y apt-transport-https curl
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" >/etc/apt/sources.list.d/kubernetes.list
  apt-get update
  apt-get install -y docker.io kubeadm

  # Run kubeadm
  kubeadm init \
    --token "${local.token}" \
    --token-ttl 15m \
    --apiserver-cert-extra-sans "${aws_eip.master.public_ip}" \
  %{if var.pod_network_cidr_block != null~}
    --pod-network-cidr "${var.pod_network_cidr_block}" \
  %{endif~}
    --node-name master

  # Prepare kubeconfig file for download to local machine
  cp /etc/kubernetes/admin.conf /home/ubuntu
  chown ubuntu:ubuntu /home/ubuntu/admin.conf
  kubectl --kubeconfig /home/ubuntu/admin.conf config set-cluster kubernetes --server https://${aws_eip.master.public_ip}:6443

  %{if var.enable_calico_cni != null~}
  kubectl --kubeconfig /home/ubuntu/admin.conf create -f https://docs.projectcalico.org/manifests/calico.yaml
  %{endif~}
  %{if var.enable_schedule_pods_on_master != null~}
  kubectl --kubeconfig /home/ubuntu/admin.conf taint nodes --all node-role.kubernetes.io/master-
  %{endif~}

  # Indicate completion of bootstrapping on this node
  touch /home/ubuntu/done
  EOF
}

resource "aws_instance" "workers" {
  count                       = var.num_workers
  ami                         = data.aws_ami.ubuntu.image_id
  instance_type               = var.worker_instance_type
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.main.key_name
  vpc_security_group_ids = [
    aws_security_group.egress.id,
    aws_security_group.ingress_internal.id,
    aws_security_group.ingress_ssh.id
  ]
  tags      = merge(local.tags, { "kubeadm:node" = "worker-${count.index}" })
  user_data = <<-EOF
  #!/bin/bash -xe

  # Install kubeadm and Docker
  apt-get update
  apt-get install -y apt-transport-https curl
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" >/etc/apt/sources.list.d/kubernetes.list
  apt-get update
  apt-get install -y docker.io kubeadm

  # Run kubeadm
  kubeadm join ${aws_instance.master.private_ip}:6443 \
    --token ${local.token} \
    --discovery-token-unsafe-skip-ca-verification \
    --node-name worker-${count.index}

  # Indicate completion of bootstrapping on this node
  touch /home/ubuntu/done
  EOF
}

#------------------------------------------------------------------------------#
# Wait for bootstrap to finish on all nodes
#------------------------------------------------------------------------------#

resource "null_resource" "wait_for_master_to_be_ready" {
  provisioner "remote-exec" {
    inline = [
      "/bin/bash -c 'while true; do [[ -f /home/ubuntu/done ]] && break || ( sleep 2; echo sleeping ); done'",
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = var.private_key_file != null ? file(var.private_key_file) : tls_private_key.ssh_server.private_key_pem
      host        = aws_eip.master.public_ip
    }
  }
  triggers = {
    "instance_ids" = aws_instance.master.id
  }
}
resource "null_resource" "wait_for_workers_to_be_ready" {
  count = var.num_workers
  
  provisioner "remote-exec" {
    inline = [
      "/bin/bash -c 'while true; do [[ -f /home/ubuntu/done ]] && break || ( sleep 2; echo sleeping ); done'",
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = var.private_key_file != null ? file(var.private_key_file) : tls_private_key.ssh_server.private_key_pem
      host        = aws_instance.workers[count.index].public_ip
    }
  }
  triggers = {
    "instance_ids" = join(",", aws_instance.workers[*].id)
  }
  depends_on = [
    null_resource.wait_for_master_to_be_ready,
  ]
}

#------------------------------------------------------------------------------#
# Download kubeconfig file from master node to local machine
#------------------------------------------------------------------------------#

locals {
  kubeconfig_file = var.kubeconfig_file != null ? abspath(pathexpand(var.kubeconfig_file)) : "${abspath(pathexpand(var.kubeconfig_dir))}/${local.cluster_name}.conf"
  kubeconfig_dir  = var.kubeconfig_dir != null ? abspath(pathexpand(var.kubeconfig_dir)) : "."
}
resource "local_file" "private_key" {
    sensitive_content  = tls_private_key.ssh_server.private_key_pem
    filename = "${path.module}/${local.cluster_name}.pem"
    file_permission = "0400"
}
resource "null_resource" "download_kubeconfig_file" {
  provisioner "local-exec" {
    command = <<-EOF 
    alias scp='scp -q -i ${var.private_key_file} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
    mkdir -p ${local.kubeconfig_dir}
    scp ubuntu@${aws_eip.master.public_ip}:/home/ubuntu/admin.conf ${local.kubeconfig_file} >/dev/null
    EOF
  }
  triggers = {
    wait_for_master_to_be_ready = null_resource.wait_for_master_to_be_ready.id
  }
}


