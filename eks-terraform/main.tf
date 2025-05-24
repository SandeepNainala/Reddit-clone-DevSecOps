# This Terraform configuration sets up an EKS cluster with a node group in AWS.
data "aws_iam_policy_document" "assume_role_policy" {
  statement {   
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# Create an EKS cluster role with the necessary policies

resource "aws_iam_role" "eks_cluster_role" {
  name               = "eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}
resource "aws_iam_role_policy_attachment" "eks_cluster_role_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

#cluster provising 

resource "aws_eks_cluster" "eks_cluster" {
  name     = "my-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.subnet01.id, aws_subnet.subnet02.id] # Replace with your subnet IDs
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_role_policy]
  
}

resource "aws_iam_role" "eks_cluster_role1" {
  name               = "eks-node-group-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}