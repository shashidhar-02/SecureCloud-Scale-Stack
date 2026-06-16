plugin "aws" {
    enabled = true
    version = "0.28.0"
    source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

rule "aws_instance_invalid_type" {
    enabled = true
}

rule "aws_s3_bucket_name_invalid" {
    enabled = true
}

rule "terraform_unused_declarations" {
    enabled = true
}

rule "terraform_deprecated_interpolation" {
    enabled = true
}

rule "terraform_typed_variables" {
    enabled = true
}
