#------------------------------------------------------------------------------#
# Required variables
#------------------------------------------------------------------------------#

variable "vpc_id" {
  type        = string
  description = "ID of an existing VPC in which to create the cluster."
}

variable "subnet_id" {
  type        = string
  description = "ID of an existing subnet in which to create the cluster. The subnet must be in the VPC specified in the \"vpc_id\" variable, otherwise an error occurs."
}

#------------------------------------------------------------------------------#
# Optional variables
#------------------------------------------------------------------------------#

variable "region" {
  type        = string
  description = "AWS region in which to create the cluster."
  default     = "eu-central-1"
}
