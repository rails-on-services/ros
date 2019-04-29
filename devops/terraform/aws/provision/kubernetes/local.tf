locals {
  eks_cluster_name = "${var.eks_clustername != "" ? var.eks_clustername : var.name}"
}
