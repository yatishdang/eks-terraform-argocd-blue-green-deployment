module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name = "minimal-vpc"
  cidr = var.vpc_cidr

  azs             = var.azs
  public_subnets  = var.public_subnets_cidr
  private_subnets = var.private_subnets_cidr

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

module "eks" {
    
    source  = "terraform-aws-modules/eks/aws"
    version = "~> 20.31"

    cluster_name                    = var.cluster_name
    cluster_version                 = var.cluster_version
    vpc_id                          = module.vpc.vpc_id
    cluster_endpoint_public_access = true
    enable_cluster_creator_admin_permissions = true
    subnet_ids = module.vpc.private_subnets

    eks_managed_node_group_defaults = {
        ami_type = "AL2_x86_64"
    }

    eks_managed_node_groups = {
        default = {
        min_size     = 1
        max_size     = 2
        desired_size = 2
        instance_types = ["t3.small"]
        }
    }

    enable_irsa = true

    # access_entries = {
    #     developers = {
    #     principal_arn     = "arn:aws:iam::831594980272:user/developers"
    #     kubernetes_groups = ["eks-admins"]
    #     }
    # }
}

# --- AWS Load Balancer Controller Helm Release ---
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  create_namespace = false
  version    = "1.7.1"

  values = [
    <<-EOF
    clusterName: ${var.cluster_name}
    serviceAccount:
      create: true
      name: aws-load-balancer-controller
      annotations:
        eks.amazonaws.com/role-arn: ${aws_iam_role.lb_controller.arn}
    region: ${var.aws_region}
    vpcId: ${module.vpc.vpc_id}
    EOF
  ]

  depends_on = [module.eks]
}

resource "aws_iam_role" "lb_controller" {
  name = "aws-load-balancer-controller"

  assume_role_policy = data.aws_iam_policy_document.lb_assume_role_policy.json
}

data "aws_iam_policy_document" "lb_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "lb_controller_attach" {
  role       = aws_iam_role.lb_controller.name
  policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
}


resource "helm_release" "argo_cd" {
  name       = "argo-cd"
  namespace  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.51.6"

  create_namespace = true
  values = [
    file("${path.module}/argocd/argocd-values.yaml")
  ]
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

data "kubernetes_ingress_v1" "argo_ingress" {
  metadata {
    name      = "argocd-server"
    namespace = "argocd"
  }

  depends_on = [helm_release.argo_cd]
}

output "alb_dns" {
  description = "DNS name of the ALB for Argo CD ingress"
  value = can(data.kubernetes_ingress_v1.argo_ingress.status[0].load_balancer[0].ingress[0].hostname) ? data.kubernetes_ingress_v1.argo_ingress.status[0].load_balancer[0].ingress[0].hostname : "pending"
}