resource "aws_iam_role" "iam-eks-master" {
  name = "${var.client}-cluster"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}
resource "aws_iam_role_policy_attachment" "iam-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.iam-eks-master.name
}
resource "aws_iam_role_policy_attachment" "iam-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role= aws_iam_role.iam-eks-master.name
}
resource "aws_iam_role" "iam-eks-node" {
  name = "${var.client}-node"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

#Policy AutoScaler attachment
resource "aws_iam_role_policy_attachment" "policy-autoscaler" {
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
  role       = aws_iam_role.iam-eks-node.name
}

resource "aws_iam_role_policy_attachment" "iam-eks-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.iam-eks-node.name
}
resource "aws_iam_role_policy_attachment" "iam-eks-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.iam-eks-node.name
}
resource "aws_iam_role_policy_attachment" "iam-eks-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.iam-eks-node.name
}
resource "aws_iam_instance_profile" "node" {
  name = "${var.client}-instance-profile"
  role = aws_iam_role.iam-eks-node.name
}

