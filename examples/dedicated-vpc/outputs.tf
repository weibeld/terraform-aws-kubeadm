output "kubeconfig" {
  value       = module.cluster.kubeconfig
  description = "Location of the kubeconfig file for the created cluster on the local machine."
}

output "cluster_name" {
  value       = module.cluster.cluster_name
  description = "Name of the created cluster. This name is used as the value of the \"kubeadm:cluster\" tag assigned to all created resources."
}

output "cluster_nodes" {
  value       = module.cluster.cluster_nodes
  description = "Names and public and private IP addresses of all the nodes of the created cluster."
}
