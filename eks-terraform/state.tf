terraform {
  backend "s3" {
    bucket = "terraform-nainala19"
    key    = "EKS/terraform.tfstate"
    region = "us-east-1"
  }
}