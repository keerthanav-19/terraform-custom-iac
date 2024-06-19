resource "aws_security_group" "sg-eks-master" {
    name        = "${var.client}-cluster"
    description = "Cluster communication with worker nodes"
    vpc_id      = var.vpc
 
    egress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    egress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = [var.s_group_vpc_cidr]
    }

    tags= {
        Name = "${var.client}-terraform-eks"
    }
}

resource "aws_security_group" "sg-eks-node" {
    name        = "${var.client}-node"
    description = "Security group for all nodes in the cluster"
    vpc_id      =  var.vpc

    egress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
 
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = [var.s_group_vpc_cidr]
    }
 
    tags= {
        Name = "${var.client}-terraform-eks"
    }
}

resource "aws_security_group_rule" "tf-eks-master-ingress-workstation-https" {
  cidr_blocks       = var.accessingip  #IP of accessing VM. Add MP server list here
  description       = "Allow workstation to communicate with the cluster API Server."
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.sg-eks-master.id
  to_port           = 443
  type              = "ingress"
}
 
resource "aws_security_group_rule" "tf-eks-node-ingress-workstation-https" {
  cidr_blocks       = var.accessingip #IP of accessing VM 
  description       = "Allow workstation to communicate with the Kubernetes nodes directly."
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.sg-eks-node.id
  to_port           = 22
  type              = "ingress"
}


resource "aws_security_group_rule" "sg-eks-node-ingress-self" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.sg-eks-node.id
  source_security_group_id = aws_security_group.sg-eks-node.id
  to_port                  = 65535
  type                     = "ingress"
}
 
resource "aws_security_group_rule" "sg-eks-node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.sg-eks-node.id
  source_security_group_id = aws_security_group.sg-eks-master.id
  to_port                  = 65535
  type                     = "ingress"
}
 
# allow worker nodes to access EKS master
resource "aws_security_group_rule" "sg-eks-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.sg-eks-node.id
  source_security_group_id = aws_security_group.sg-eks-master.id
  to_port                  = 443
  type                     = "ingress"
}
 
resource "aws_security_group_rule" "sg-eks-node-ingress-master" {
  description              = "Allow cluster control to receive communication from the worker Kubelets"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.sg-eks-master.id
  source_security_group_id = aws_security_group.sg-eks-node.id
  to_port                  = 443
  type                     = "ingress"
}

