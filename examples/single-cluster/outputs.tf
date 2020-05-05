output "kubeconfig" {
  value       = module.cluster.kubeconfig
  description = "Location of the kubeconfig file of the created cluster on the local machine."
}

output "nodes" {
  value       = module.cluster.cluster_nodes
  description = "Names and public/private IP addresses of the nodes of the cluster."
}
