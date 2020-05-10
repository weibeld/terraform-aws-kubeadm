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

variable "cluster_names" {
  type        = tuple([string, string, string])
  description = "Names for the individual clusters. If the value for a specific cluster is null, a random name will be automatically chosen."
  default     = [null, null, null]
}

variable "region" {
  type        = string
  description = "AWS region in which to create the clusters."
  default     = "eu-central-1"
}
