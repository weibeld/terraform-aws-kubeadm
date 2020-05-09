output "kubeconfigs" {
  value = {
    (var.cluster_1_name) = module.cluster_1.kubeconfig
    (var.cluster_2_name) = module.cluster_2.kubeconfig
    (var.cluster_3_name) = module.cluster_3.kubeconfig
  }
  description = "Locations of the kubeconfig files for each cluster."
}

output "clusters" {
  value = {
    (var.cluster_1_name) = module.cluster_1.cluster_nodes
    (var.cluster_2_name) = module.cluster_2.cluster_nodes
    (var.cluster_3_name) = module.cluster_3.cluster_nodes
  }
  description = "Names and IP addresses of the nodes of each cluster."
}
