variable "access_key" {}
variable "secret_key" {}
variable "public_key" {}

variable "region" {
  default = "us-east-2"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  description = "compucorp key pair"
  default     = "compucorp_key"
}