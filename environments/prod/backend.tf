terraform {
  backend "s3" {
    bucket         = "securecloud-terraform-state-prod-12345"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "securecloud-terraform-locks-prod"
  }
}
