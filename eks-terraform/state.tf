terraform {
  backend "s3" {
    bucket = "terraform-nainala9"
    key    = "EKS/terraform.tfstate"
    region = "us-east-1"
  }
}