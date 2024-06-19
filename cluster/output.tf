output "cluster_name"{
value= aws_eks_cluster.eks_cluster.id
}
output "cluster_endpoint"{
value= aws_eks_cluster.eks_cluster.endpoint
}
