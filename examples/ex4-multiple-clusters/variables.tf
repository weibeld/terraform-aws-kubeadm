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

#------------------------------------------------------------------------------#
# Optional variables
#------------------------------------------------------------------------------#

variable "cluster_1_name" {
  type        = string
  description = "Name of the first cluster."
  default     = "cluster-1"
}

variable "cluster_2_name" {
  type        = string
  description = "Name of the second cluster."
  default     = "cluster-2"
}

variable "cluster_3_name" {
  type        = string
  description = "Name of the third cluster."
  default     = "cluster-3"
}

variable "region" {
  type        = string
  description = "AWS region in which to create the clusters."
  default     = "eu-central-1"
}
