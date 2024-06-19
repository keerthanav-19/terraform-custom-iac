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
variable "availability_zone" {
  default = {
    zone1 = "a"
    zone2 = "b"
  }
}
 variable "client" {
 default = "###CLIENT###"
 }

variable "instance_type" {
default = ["###NODE_TYPE###"]
}

#IP of the bastion from where scripts are triggerred
variable "accessingip" {
default = ["###NATIP###"]
}

variable "min_node_count"{
default = "###NODE_COUNT###"
}

variable "max_node_count"{
default = "10"
}

variable "access_key" {
default="###ACCESS_KEY###"
}
variable "secret_key" {
default="###SECRET_KEY###"
}

variable "gateway_id" {
default = "###GATEWAY_ID###"
#default = "igw-0f3e473f8d83abbea"
}

variable "vpc" {
default = "###VPC_ID###"
#default = "vpc-08fd032cc26726221"
}

variable "ownertag" {
  default = "###OWNER_TAG###"
}
