provider "aws" {
  region = var.region
}

module "cluster" {
  source  = "weibeld/kubeadm/aws"
  version = "~> 0.2"
}
