variable "localhost_ip" {
  type        = string
  description = "IP address of the local machine (this IP address will get SSH access to the cluster nodes)."
}

variable "private_key_file" {
  type        = string
  description = "Private key file of a public/private key-pair on the local machine."
}

variable "public_key_file" {
  type        = string
  description = "Public key file of a public/private key-pair on the local machine (must be in OpenSSH format)."
}

variable "pod_network_cidr" {
  type        = string
  description = "IP address range of the Pod network. If set, appropriate Pod subnet IP address ranges will be automatically allocated to the nodes; if unset (default value \"\"), no Pod subnet allocation takes place."
  default     = ""
}

variable "node_network_cidr" {
  type        = string
  description = "IP address range of the VPC subnet in which the cluster will be created (determines the private IP addresses of the cluster nodes)."
  default     = "172.16.0.0/16"
}

variable "master_instance_type" {
  type        = string
  description = "EC2 instance type for the master node (must have at least 2 CPUs)."
  default     = "t2.medium"
}

variable "worker_instance_type" {
  type        = string
  description = "EC2 instance type for the worker nodes."
  default     = "t2.small"
}

variable "num_workers" {
  type        = number
  description = "Number of worker nodes."
  default     = 2
}

variable "region" {
  type        = string
  description = "AWS region in which to create the cluster."
  default     = "eu-central-1"
}
