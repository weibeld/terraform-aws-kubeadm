provider "aws" {
  region = var.region
}

module "cluster" {
  source    = "weibeld/kubeadm/aws"
  version   = "~> 0.2"
  vpc_id    = var.vpc_id
  subnet_id = var.subnet_id
}
