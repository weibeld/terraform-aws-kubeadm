output "kubeconfig" {
  description = "Location of the kubeconfig file for the created cluster on the local machine."
  value = data.null_data_source.kubeconfig_file.outputs["kubeconfig_file"]
}

output "cluster_name" {
  value       = local.cluster_name
  description = "Name of the created cluster. This name is used as the value of the \"kubeadm:cluster\" tag assigned to all created AWS resources."
}
output "cluster_master_ip" {
  value       = aws_eip_association.master.public_ip
  description = "The public IP associated with the master node."
}

output "cluster_nodes" {
  value = [
    for i in concat([aws_instance.master], aws_instance.workers, ) : {
      name       = i.tags["kubeadm:node"]
      subnet_id  = i.subnet_id
      private_ip = i.private_ip
      public_ip  = i.tags["kubeadm:node"] == "master" ? aws_eip.master.public_ip : i.public_ip
    }
  ]
  description = "Name, public and private IP address, and subnet ID of all nodes of the created cluster."
}

output "vpc_id" {
  value       = aws_security_group.egress.vpc_id
  description = "ID of the VPC in which the cluster has been created."
}

output "ssh_key_pair" {
  value = {
    public_key = tls_private_key.ssh_server.public_key_openssh
    private_key = tls_private_key.ssh_server.private_key_pem
  }
  sensitive = true
}