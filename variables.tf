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
  description = "CIDR blocks that are allowed to make Kubernetes API requests to the API server of the cluster. By default, Kubernetes API requests are allowed from everywhere. Note that Kubernetes API requests from nodes and pods inside the cluster are always allowed, regardless of the value of this variable."
  default     = ["0.0.0.0/0"]
}

variable "pod_network_cidr" {
  type        = string
  description = "IP address range of the Pod network. If set, appropriate Pod subnet IP address ranges will be automatically allocated to the nodes; if unset (default value \"\"), no Pod subnet allocation takes place."
  default     = ""
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
