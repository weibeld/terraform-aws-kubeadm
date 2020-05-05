provider "aws" {
  # Credentials are read from ~/.aws/credentials or from the corresponding
  # environment variables AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY.
  region = var.region
}

module "cluster" {
  source  = "weibeld/kubeadm/aws"
  version = "0.0.2"

  # Required variables
  private_key_file = var.private_key
  public_key_file  = var.public_key

  # Optional variables
  cluster_name           = "single-cluster"
  pod_network_cidr_block = var.pod_network_cidr
  num_workers            = var.num_workers
}
