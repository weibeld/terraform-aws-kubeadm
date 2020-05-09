#------------------------------------------------------------------------------#
# Required variables
#------------------------------------------------------------------------------#

variable "private_key_file" {
  type        = string
  description = "Private key file of a key-pair on the local machine (e.g. ~/.ssh/id_rsa)."
}

variable "public_key_file" {
  type        = string
  description = "Public key file (in OpenSSH format) of a key-pair on the local machine (e.g. ~/.ssh/id_rsa.pub)."
}

variable "vpc_id" {
  type        = string
  description = "ID of the AWS VPC in which to create the cluster."
}

variable "subnet_id" {
  type        = string
  description = "ID of the AWS subnet in which to create the cluster. The subnet must be in the VPC specified by var.vpc_id."
}

#------------------------------------------------------------------------------#
# Optional variables
#------------------------------------------------------------------------------#

variable "kubeconfig_dir" {
  type        = string
  description = "Directory on the local machine in which to save the kubeconfig file of the created cluster. The kubeconfig file will have a basename of the form \"cluster_name.conf\" where \"cluster_name\" is the name of the cluster as defined by var.cluster_name (or generated randomly if var.cluster_name is not set). The directory may be specified as an absolute or relative path. The directory must exist, otherwise an error occcurs. By default, the current working directory is used."
  default     = "."
}

variable "kubeconfig_file" {
  type        = string
  description = "_This is an optional variable._ Exact filename as which to save the kubeconfig file of the created cluster on the local machine. May be an absolute or relative path. The parent directory of the specified filename must exist, otherwise an error occurs. If a file with the same name already exists, it will be overwritten. If this variable is set to a value other than null, then the value of var.kubeconfig_dir is ignored."
  default     = null
}

variable "cluster_name" {
  type        = string
  description = "Name for the Kubernetes cluster. This name will be used for tagging the created AWS resources. If set to null, a random name is automatically generated."
  default     = null
}

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
  description = "CIDR block for the Pod network of the cluster. If set to a valid value, Kubernetes automatically allocates Pod subnet IP address ranges to the nodes (sets the .spec.podCIDR field of the node objects). If set to null, the cluster is created without an explicitly determined Pod network IP address range, and the nodes receive no Pod subnet IP address range allocations (the .spec.podCIDR field of the nodes is not set)."
  default     = null
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
