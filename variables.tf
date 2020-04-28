variable "localhost_ip" {
  type        = string
  description = "IP address of the local machine (this IP address will get SSH access to the instances)."
}

variable "public_key_file" {
  type        = string
  description = "Public key file in OpenSSH format on the local machine (e.g. '~/.ssh/id_rsa.pub')."
}

variable "region" {
  type        = string
  description = "AWS region in which to create the resources."
  default     = "eu-central-1"
}

