# Variables 
# ---- key values are stored in *.tfvars file ----- so it will not in GitHub
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "key_name" {}
variable "private_key_path" {}
variable "region" {
  default = "us-east-1"
}