output "sg-eks-master"{
value = aws_security_group.sg-eks-master.id
}

output "sg-eks-node"{
value = aws_security_group.sg-eks-node.id
}
