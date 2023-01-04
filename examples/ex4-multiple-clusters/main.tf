provider "aws" {
  region = var.region
}

module "network" {
  source  = "weibeld/kubeadm/aws//modules/network"
  version = "~> 0.2"
  tags = merge(local.additional_tags, {"Name" = "terraform-kubeadm"})
}

module "cluster_1" {
  source       = "../.."
  cluster_name = var.cluster_names[0]
  vpc_id = module.network.vpc_id
  subnet_id = module.network.subnet_id
  tags = merge(local.additional_tags, {"Name" = var.cluster_names[0]})
}

module "cluster_2" {
  source       = "../.."
  cluster_name = var.cluster_names[1]
  vpc_id = module.network.vpc_id
  subnet_id = module.network.subnet_id
  tags = merge(local.additional_tags, {"Name" = var.cluster_names[1]})
}

module "cluster_3" {
  source       = "../.."
  cluster_name = var.cluster_names[2]
  vpc_id = module.network.vpc_id
  subnet_id = module.network.subnet_id
  tags = merge(local.additional_tags, {"Name" = var.cluster_names[2]})

}

locals {
  additional_tags = {"Environment" = terraform.workspace}
}