output "iam_role_master"{
value= aws_iam_role.iam-eks-master.arn
}

output "instance_profile_node"{
value = aws_iam_instance_profile.node.name
}

output "iam_role_node"{
value= aws_iam_role.iam-eks-node.arn
}
