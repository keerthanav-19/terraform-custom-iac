terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.9.0"
    }
  }
}

provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

variable "vpc_cidr_block" {
default= "10.0.0.0/16"
}
variable "region"{
default= "###REGION###"
}
variable "client" {
default = "###CLIENT###"
}
variable "access_key" {
default="###ACCESS_KEY###"
}
variable "secret_key" {
default="###SECRET_KEY###"
}
