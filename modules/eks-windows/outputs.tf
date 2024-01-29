output "eks_cluster_name" {
  value = aws_eks_cluster.eks_windows.name
}

output "eks_cluster_status" {
  value = aws_eks_cluster.eks_windows.status
}
