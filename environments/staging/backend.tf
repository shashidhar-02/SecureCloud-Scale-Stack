terraform {
  backend "s3" {
    bucket         = "securecloud-terraform-state-staging-12345"
    key            = "staging/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "securecloud-terraform-locks-staging"
  }
}
