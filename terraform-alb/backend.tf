terraform {
  backend "s3" {
    bucket = "terraform-states-816069165502"
    key    = "terraform-alb/terraform.tfstate"
    region = "us-east-1"
  }
}
