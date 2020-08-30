provider "aws" {
  region = var.region
}

module "network" {
  source     = "weibeld/kubeadm/aws//modules/network"
  version    = "~> 0.2"
  cidr_block = "10.0.0.0/16"
  tags       = { "terraform-kubeadm:cluster" = module.cluster.cluster_name }
}

module "cluster" {
  source    = "weibeld/kubeadm/aws"
  version   = "~> 0.2"
  vpc_id    = module.network.vpc_id
  subnet_id = module.network.subnet_id
}
