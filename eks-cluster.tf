module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.0.4"

  cluster_name    = var.eks_cluster_name
  cluster_version = var.k8s_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }
  eks_managed_node_groups = {
    one = {
      name = "eks-node-group-1"

      instance_types = [var.ec2_nodes_type]

      min_size     = var.number_of_worker_nodes
      max_size     = var.number_of_worker_nodes
      desired_size = var.number_of_worker_nodes

      key_name = var.eks_managed_node_groups_ssh_key_pair
    }
  }
}
# creates IAM role for ebs-csi-controller and assigns AmazonEBSCSIDriverPolicy policy to it
module "iam_eks_role" {
  
  source = "terraform-aws-modules/iam/aws//modules/iam-eks-role"

  role_name = "${var.ebs-csi-controller-role-name}"

  cluster_service_accounts = {
    (module.eks.cluster_name) = ["kube-system:ebs-csi-controller-sa"]
  }
  role_policy_arns = {
    "arn" = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  }
  depends_on = [
     module.eks.cluster_name # implicit dependancy doesn't work for some reason ...
  ]
}