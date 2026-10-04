#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:-}"
REGION="${2:-${AWS_REGION:-us-east-1}}"

case "$ENVIRONMENT" in
  dev|staging|prod) ;;
  *)
    echo "Usage: $0 <dev|staging|prod> [aws-region]" >&2
    exit 2
    ;;
esac

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
BUCKET_NAME="securecloud-terraform-state-${ACCOUNT_ID}-${ENVIRONMENT}"
DYNAMO_TABLE="securecloud-terraform-locks-${ENVIRONMENT}"

echo "Ensuring S3 bucket $BUCKET_NAME exists in $REGION..."
if ! aws s3api head-bucket --bucket "$BUCKET_NAME" --region "$REGION" 2>/dev/null; then
  if [[ "$REGION" == "us-east-1" ]]; then
    aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION"
  else
    aws s3api create-bucket \
      --bucket "$BUCKET_NAME" \
      --region "$REGION" \
      --create-bucket-configuration "LocationConstraint=$REGION"
  fi
fi

echo "Enabling bucket versioning, encryption, and public-access blocking..."
aws s3api put-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --versioning-configuration Status=Enabled
aws s3api put-bucket-encryption \
  --bucket "$BUCKET_NAME" \
  --server-side-encryption-configuration \
  '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
aws s3api put-public-access-block \
  --bucket "$BUCKET_NAME" \
  --public-access-block-configuration \
  "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

echo "Ensuring DynamoDB state-lock table $DYNAMO_TABLE exists..."
if ! aws dynamodb describe-table --table-name "$DYNAMO_TABLE" --region "$REGION" >/dev/null 2>&1; then
  aws dynamodb create-table \
    --table-name "$DYNAMO_TABLE" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "$REGION"
fi
aws dynamodb wait table-exists --table-name "$DYNAMO_TABLE" --region "$REGION"

echo "Backend bootstrap complete for $ENVIRONMENT."
echo "Run: make init ENV=$ENVIRONMENT AWS_REGION=$REGION"
