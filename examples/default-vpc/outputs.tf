output "kubeconfig" {
  value       = module.cluster.kubeconfig
  description = "Absolute path of the kubeconfig file of the created cluster on the local machine."
}

output "cluster_name" {
  value       = module.cluster.cluster_name
  description = "Name of the created cluster. This name is used as the value of the \"kubeadm:cluster\" tag assigned to all created resources."
}

output "cluster_nodes" {
  value       = module.cluster.cluster_nodes
  description = "Name, public and private IP address, and subnet ID of all nodes of the created cluster."
}

output "vpc_id" {
  value       = module.cluster.vpc_id
  description = "ID of the AWS VPC in which the cluster has been created."
}
