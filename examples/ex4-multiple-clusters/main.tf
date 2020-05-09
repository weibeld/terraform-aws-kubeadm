provider "aws" {
  region = var.region
}

module "cluster_1" {
  source           = "weibeld/kubeadm/aws"
  version          = "~> 0.0"
  private_key_file = var.private_key_file
  public_key_file  = var.public_key_file
  cluster_name     = var.cluster_1_name
  kubeconfig_file  = "${var.cluster_1_name}.conf"
}

module "cluster_2" {
  source           = "weibeld/kubeadm/aws"
  version          = "~> 0.0"
  private_key_file = var.private_key_file
  public_key_file  = var.public_key_file
  cluster_name     = var.cluster_2_name
  kubeconfig_file  = "${var.cluster_2_name}.conf"
}

module "cluster_3" {
  source           = "weibeld/kubeadm/aws"
  version          = "~> 0.0"
  private_key_file = var.private_key_file
  public_key_file  = var.public_key_file
  cluster_name     = var.cluster_3_name
  kubeconfig_file  = "${var.cluster_3_name}.conf"
}
