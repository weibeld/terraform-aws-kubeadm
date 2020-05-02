output "kubeconfig" {
  value = {
    file = local.kubeconfig_path
    env  = "export KUBECONFIG=${local.kubeconfig_path}"
  }
}

output "nodes" {
  value = [
    for i in concat([aws_instance.master], aws_instance.workers, ) : {
      name       = i.tags["k8s-node"]
      private_ip = i.private_ip
      public_ip  = i.tags["k8s-node"] == "master" ? aws_eip.master.public_ip : i.public_ip
    }
  ]
}
