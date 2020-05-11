output "cluster_names" {
  value = [
    for c in [
      module.cluster_1,
      module.cluster_2,
      module.cluster_3,
    ] :
    c.cluster_name
  ]
  description = "Names of the created clusters."
}

output "cluster_nodes" {
  value = {
    for c in [
      module.cluster_1,
      module.cluster_2,
      module.cluster_3,
    ] :
    (c.cluster_name) => c.cluster_nodes
  }
  description = "Details about the nodes of the created clusters."
}

output "kubeconfigs" {
  value = {
    for c in [
      module.cluster_1,
      module.cluster_2,
      module.cluster_3,
    ] :
    (c.cluster_name) => c.kubeconfig
  }
  description = "Locations of the kubeconfig files of the created clusters."
}
