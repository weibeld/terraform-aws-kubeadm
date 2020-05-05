variable "num_workers" {
  type        = number
  description = "Number of worker nodes."
  default     = 3
}

variable "pod_network_cidr" {
  type        = string
  description = "IP address range of the Pod network of the cluster in CIDR format."
  default     = "10.244.0.0/16"
}

variable "public_key" {
  type        = string
  description = "Path to a file with a public key in OpenSSH format. The public key must belong to var.private_key."
  default     = "~/.ssh/id_rsa.pub"
}

variable "private_key" {
  type        = string
  description = "Path to a file with a private key. The private key must belong to var.public_key."
  default     = "~/.ssh/id_rsa"
}

variable "region" {
  type        = string
  description = "AWS region in which to create the cluster."
  default     = "eu-central-1"
}
