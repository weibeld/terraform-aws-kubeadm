provider "aws" {
  region = var.region
}

module "cluster_1" {
  source       = "weibeld/kubeadm/aws"
  version      = "~> 0.2"
  cluster_name = var.cluster_names[0]
}

module "cluster_2" {
  source       = "weibeld/kubeadm/aws"
  version      = "~> 0.2"
  cluster_name = var.cluster_names[1]
}

module "cluster_3" {
  source       = "weibeld/kubeadm/aws"
  version      = "~> 0.2"
  cluster_name = var.cluster_names[2]
}
