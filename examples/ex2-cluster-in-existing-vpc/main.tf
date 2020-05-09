provider "aws" {
  region = var.region
}

module "cluster" {
  source           = "weibeld/kubeadm/aws"
  version          = "~> 0.0"
  private_key_file = var.private_key_file
  public_key_file  = var.public_key_file
  vpc_id           = var.vpc_id
  subnet_id        = var.subnet_id
}
