output "kubeconfig" {
  value       = local.kubeconfig_file
  description = "Location of the kubeconfig file for the created cluster on the local machine."
}

output "cluster_name" {
  value       = local.cluster_name
  description = "Name of the created cluster. This name is used as the value of the \"terraform-kubeadm:cluster\" tag assigned to all created AWS resources."
}

output "cluster_nodes" {
  value = [
    for i in concat([aws_instance.master], aws_instance.workers, ) : {
      name       = i.tags["terraform-kubeadm:node"]
      subnet_id  = i.subnet_id
      private_ip = i.private_ip
      public_ip  = i.tags["terraform-kubeadm:node"] == "master" ? aws_eip.master.public_ip : i.public_ip
    }
  ]
  description = "Name, public and private IP address, and subnet ID of all nodes of the created cluster."
}

output "vpc_id" {
  value       = aws_security_group.egress.vpc_id
  description = "ID of the VPC in which the cluster has been created."
}
