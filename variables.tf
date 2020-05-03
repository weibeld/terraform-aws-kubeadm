#------------------------------------------------------------------------------#
# Required variables
#------------------------------------------------------------------------------#

variable "private_key_file" {
  type        = string
  description = "Private key file of a public/private key-pair on the local machine."
}

variable "public_key_file" {
  type        = string
  description = "Public key file of a public/private key-pair on the local machine (must be in OpenSSH format)."
}

#------------------------------------------------------------------------------#
# Optional variables
#------------------------------------------------------------------------------#

variable "allowed_ssh_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks that are allowed to make SSH connections to the EC2 instances. By default, SSH connections are allowed from everywhere."
  default     = ["0.0.0.0/0"]
}

variable "allowed_k8s_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks that are allowed to make Kubernetes API requests to the API server of the cluster. By default, Kubernetes API requests are allowed from everywhere. Note that Kubernetes API requests from nodes and Pods inside the cluster are always allowed, regardless of the value of this variable."
  default     = ["0.0.0.0/0"]
}

variable "pod_network_cidr_block" {
  type        = string
  description = "CIDR block for the Pod network of the cluster. If set, Kubernetes automatically allocates Pod subnet IP address ranges to the nodes (sets field .spec.podCIDR of the node objects). If unset, the cluster is created without an explicitly determined Pod network IP address range, and the nodes receive no Pod subnet IP address range allocations (the .spec.podCIDR field of the nodes is not set)."
  default     = null
}

variable "host_network_cidr" {
  type        = string
  description = "IP address range of the host network (private IP addresses of the cluster nodes)."
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
