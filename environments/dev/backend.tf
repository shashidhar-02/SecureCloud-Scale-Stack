terraform {
  backend "s3" {
    # Replace with your actual S3 bucket and DynamoDB table names
    bucket         = "securecloud-terraform-state-dev-12345"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "securecloud-terraform-locks-dev"
  }
}
