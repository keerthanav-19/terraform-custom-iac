resource "aws_eks_cluster" "eks_cluster" {
  name            = var.eks_cluster_name
  role_arn        = var.iam_role_master
 version = "1.27"
  vpc_config {
    security_group_ids = [var.sg-eks-master]
    subnet_ids = [var.subnet_private1, var.subnet_private2,var.subnet_public1,var.subnet_public2]
    endpoint_private_access= true
    endpoint_public_access = true
        public_access_cidrs = var.accessingip #bastion IP
  }
  tags = {
    resource_owner = var.ownertag
  }
}

resource "aws_cloudwatch_log_group" "cluster-loggroup" {
  name              = "/aws/eks/${var.client}/cluster"
  kms_key_id = var.kms_arn
  tags = {
    Name = "log-group-${var.client}"
    owner = "multicloud_${var.client}"
    resource_owner = var.ownertag
  }
}

locals {
iam-eks-node-userdata = <<USERDATA
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="

--==MYBOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh ${var.client} --kubelet-extra-args --b64-cluster-ca '${aws_eks_cluster.eks_cluster.certificate_authority.0.data}'  --apiserver-endpoint '${aws_eks_cluster.eks_cluster.endpoint}' --dns-cluster-ip '${aws_eks_cluster.eks_cluster.endpoint}' --container-runtime containerd

--==MYBOUNDARY==--

USERDATA
}

resource "aws_launch_template" "eks_cluster_launch" {
  name = "lc-${var.client}"
  vpc_security_group_ids = [var.sg-eks-node]
    block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      encrypted = true
      #kms_key_id = var.kms_arn
}
}

  user_data = base64encode(local.iam-eks-node-userdata)
  
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "node-${var.client}-terraform-tf-eks"
      owner = "multicloud_${var.client}"
      resource_owner = var.ownertag
    }
   }
 }


resource "aws_eks_node_group" "eks_cluster" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  ami_type = "AL2_x86_64"
  instance_types = var.instance_type
  node_group_name = "np-${var.client}"
  node_role_arn   = var.iam_role_node
  subnet_ids      = [var.subnet_private1, var.subnet_private2]

  tags = {
    resource_owner = var.ownertag
  }

  scaling_config {
    desired_size = var.min_node_count
    max_size     = var.max_node_count
    min_size     = var.min_node_count
    #security_groups             = [var.sg-eks-node]
  }
  launch_template {
      name      = aws_launch_template.eks_cluster_launch.name
      version = aws_launch_template.eks_cluster_launch.latest_version
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  
}
