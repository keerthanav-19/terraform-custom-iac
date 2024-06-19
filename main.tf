module "vpc"{
source = "./vpc"
client = var.client
vpc_cidr_block = var.vpc_cidr_block
eks_cluster_name = "cluster-${var.client}"
ownertag = var.ownertag
}

module "kms"{
source = "./kms"
region   = var.region
}

module "subnet"{
source = "./subnet"
client = var.client
vpc = module.vpc.network_id
region = var.region
vpc_cidr_block = var.vpc_cidr_block
availability_zone_one = var.availability_zone["zone1"]
availability_zone_two = var.availability_zone["zone2"]
eks_cluster_name = "cluster-${var.client}"
}

module "eip" {
  source = "./eip"
}

module "ig" {
source = "./ig"
vpc = module.vpc.network_id
client = var.client
}

module "gateways"{
source = "./gateways"
client = var.client
vpc =  module.vpc.network_id
nat_gateway_eip1 = module.eip.nat_gateway_eip1
nat_gateway_eip2 = module.eip.nat_gateway_eip2
subnet_public1 = module.subnet.subnet_public1
subnet_public2 = module.subnet.subnet_public2
subnet_private1 = module.subnet.subnet_private1
subnet_private2 = module.subnet.subnet_private2
gateway_id = module.ig.igid
}

module "security_groups"{
source = "./security_groups"
client = var.client
vpc = module.vpc.network_id
accessingip = var.accessingip
s_group_vpc_cidr = var.vpc_cidr_block
}

module "iam_role"{
source = "./iam_role"
client = var.client
}

module "s3" {
source = "./s3"
region = var.region
client = var.client
}

module "cluster"{
source = "./cluster"
client = var.client
iam_role_master = module.iam_role.iam_role_master
iam_role_node = module.iam_role.iam_role_node
subnet_private1 = module.subnet.subnet_private1
subnet_private2 = module.subnet.subnet_private2
subnet_public1 = module.subnet.subnet_public1
subnet_public2 = module.subnet.subnet_public2
sg-eks-master = module.security_groups.sg-eks-master
sg-eks-node = module.security_groups.sg-eks-node
eks_cluster_name = "cluster-${var.client}"
instance_type = var.instance_type
accessingip = var.accessingip
max_node_count = var.max_node_count
min_node_count = var.min_node_count
kms_arn = module.kms.kms_arn
ownertag = var.ownertag
}

