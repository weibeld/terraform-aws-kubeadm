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
