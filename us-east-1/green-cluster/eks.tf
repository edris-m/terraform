provider "aws" {
  region  = var.region
}

provider "kubernetes" {
  config_path = "~/.kube/config"
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", "var.cluster_name"]
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

data "aws_caller_identity" "current" {}

module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name = var.cluster_name
  cluster_version = "1.22"

  vpc_id = var.vpc_id
  subnet_ids = var.subnet_ids

  create_iam_role = "true"
  create_cluster_security_group = "true"
  create_node_security_group = "true"
  create_cloudwatch_log_group = "false"

  cluster_addons = {
    coredns = {
      preserve  = true
      most_recent = true
    }

    vpc-cni = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    green-cluster-ng  = {
      disk_size = var.disk_size
      create_launch_template  = true
      create_iam_role         = true
      min_size                = var.minimum
      max_size                = var.maximum
      desired_size            = var.desired
      subnet_ids              = var.subnets

      instance_type           = var.instance
      key_name                = var.ssh_key
      
      iam_role_additional_policies  = {
        additional            = aws_iam_policy.green-cluster-autoscaler.arn
      }

    }
  }

  managed_aws_auth_configmap  = true
  aws_auth_roles = var.auth_roles

  tags = {
    Environment = var.environment
    Name        = var.cluster_name
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
    "k8s.io/cluster-autoscaler/enabled" = "true"
  }
}


resource "aws_iam_policy" "green-cluster-autoscaler" {
  name = "${var.cluster_name}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/k8s.io/cluster-autoscaler/my-cluster": "owned"
                }
            }
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeAutoScalingGroups",
                "ec2:DescribeLaunchTemplateVersions",
                "autoscaling:DescribeTags",
                "autoscaling:DescribeLaunchConfigurations",
                "ec2:DescribeInstanceTypes"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

data "aws_key_pair" "ssh_key" {
  key_name = "${var.ssh_key}"
}
