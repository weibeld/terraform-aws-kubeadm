variable "private_key_file" {
  type        = string
  description = "Filename of the private key of a key pair on your local machine. This key pair will allow to connect to the nodes of the cluster with SSH."
  default     = "~/.ssh/id_rsa"
}

variable "public_key_file" {
  type        = string
  description = "Filename of the public key of a key pair on your local machine. This key pair will allow to connect to the nodes of the cluster with SSH."
  default     = "~/.ssh/id_rsa.pub"
}

variable "vpc_id" {
  type        = string
  description = "**This is an optional variable with a default value of null**. ID of the AWS VPC in which to create the cluster. If null, the default VPC is used."
  default     = null
}

variable "subnet_id" {
  type        = string
  description = "**This is an optional variable with a default value of null**. ID of the AWS subnet in which to create the cluster. If null, one of the default subnets in the default VPC is used. The subnet must be in the VPC specified by the \"vpc_id\" variable, otherwise an error occurs."
  default     = null
}

variable "kubeconfig_dir" {
  type        = string
  description = "Directory on the local machine in which to save the kubeconfig file of the created cluster. The basename of the kubeconfig file will consist of the cluster name followed by \".conf\", for example, \"my-cluster.conf\". The directory may be specified as an absolute or relative path. The directory must exist, otherwise an error occurs. By default, the current working directory is used."
  default     = "."
}

variable "kubeconfig_file" {
  type        = string
  description = "**This is an optional variable with a default value of null**. The exact filename as which to save the kubeconfig file of the crated cluster on the local machine. The filename may be specified as an absolute or relative path. The parent directory of the filename must exist, otherwise an error occurs. If a file with the same name already exists, it will be overwritten. If this variable is set to a value other than null, the value of the \"kubeconfig_dir\" variable is ignored."
  default     = null
}

variable "cluster_name" {
  type        = string
  description = "**This is an optional variable with a default value of null**. Name for the Kubernetes cluster. This name will be used as the value for the \"terraform-kubeadm:cluster\" tag that is assigned to all created AWS resources. If null, a random name is automatically chosen."
  default     = null
}

variable "allowed_ssh_cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks from which it is allowed to make SSH connections to the EC2 instances that form the cluster nodes. By default, SSH connections are allowed from everywhere."
  default     = ["0.0.0.0/0"]
}

variable "allowed_k8s_cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks from which it is allowed to make Kubernetes API request to the API server of the cluster. By default, Kubernetes API requests are allowed from everywhere. Note that Kubernetes API requests from Pods and nodes inside the cluster are always allowed, regardless of the value of this variable."
  default     = ["0.0.0.0/0"]
}

variable "pod_network_cidr_block" {
  type        = string
  description = "**This is an optional variable with a default value of null**. CIDR block for the Pod network of the cluster. If set, Kubernetes automatically allocates Pod subnet IP address ranges to the nodes (i.e. sets the \".spec.podCIDR\" field of the node objects). If null, the cluster is created without an explicitly determined Pod network IP address range, and the nodes are not allocated any Pod subnet IP address ranges (i.e. the \".spec.podCIDR\" field of the nodes is not set)."
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

variable "tags" {
  type        = map(string)
  description = "A set of tags to assign to the created AWS resources. These tags will be assigned in addition to the default tags. The default tags include \"terraform-kubeadm:cluster\" which is assigned to all resources and whose value is the cluster name, and \"terraform-kubeadm:node\" which is assigned to the EC2 instances and whose value is the name of the Kubernetes node that this EC2 corresponds to."
  default     = {}
}
