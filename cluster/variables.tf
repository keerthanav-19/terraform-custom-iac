variable "iam_role_master" {}
variable "iam_role_node" {}
variable "subnet_private1"{}
variable "subnet_private2"{}
variable "sg-eks-master" {}
variable "sg-eks-node" {}
#variable "instance_profile_node" {}
variable "eks_cluster_name" {}
#variable "image_id" {}
variable "instance_type" {}
variable "client" {}
variable "min_node_count" {}
variable "max_node_count" {}
variable "subnet_public1" {}
variable "subnet_public2" {}
variable "accessingip" {
type= list(string)
}
variable "kms_arn" {}
variable "ownertag" {}
