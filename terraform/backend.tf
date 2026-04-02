terraform {
  backend "s3" {
    bucket = "${var.bucket_name}-tf-state"
    key    = "terraform/bronze/terraform.tfstate"
    region = "us-east-1"
  }
}