#!/bin/bash

set -e

# Prompt user for details
read -p "Enter a unique S3 bucket name (e.g., mysite-example-com): " BUCKET_NAME
read -p "Enter the full domain name (e.g., example.com): " DOMAIN_NAME

echo "Which DNS provider will you use?"
echo "1) Route 53"
echo "2) Cloudflare"
read -p "Enter 1 or 2: " DNS_PROVIDER

if [[ "$DNS_PROVIDER" == "2" ]]; then
  echo "You selected Cloudflare. Using CloudFront OAI for secure delivery."
  POLICY_TEMPLATE="templates/bucket-policy-oai.json"
  read -p "Enter CloudFront OAI ID (e.g., E1234567890ABC): " OAI_ID
  echo "Fetching CanonicalUser ID for OAI..."
  CANONICAL_USER_ID=$(aws cloudfront get-cloud-front-origin-access-identity --id "$OAI_ID" --query 'CloudFrontOriginAccessIdentity.S3CanonicalUserId' --output text)
  echo "Canonical User ID: $CANONICAL_USER_ID"
else
  echo "You selected Route 53. Using public-read policy."
  POLICY_TEMPLATE="templates/bucket-policy.json"
fi

# Create the bucket
echo "Creating bucket $BUCKET_NAME..."
aws s3api create-bucket \
  --bucket "$BUCKET_NAME" \
  --region $(aws configure get region) \
  --create-bucket-configuration LocationConstraint=$(aws configure get region) || true

# Set up website configuration
aws s3 website s3://$BUCKET_NAME/ \
  --index-document index.html \
  --error-document 404.html || true

# Prepare bucket policy
TEMP_POLICY_FILE="temp-policy.json"
cp "$POLICY_TEMPLATE" "$TEMP_POLICY_FILE"
sed -i '' "s|__BUCKET_NAME__|$BUCKET_NAME|g" "$TEMP_POLICY_FILE"
if [[ "$DNS_PROVIDER" == "2" ]]; then
  sed -i '' "s|__OAI_CANONICAL_ID__|$CANONICAL_USER_ID|g" "$TEMP_POLICY_FILE"
fi

# Apply the bucket policy
echo "Applying bucket policy..."
aws s3api put-bucket-policy \
  --bucket "$BUCKET_NAME" \
  --policy file://$TEMP_POLICY_FILE

rm "$TEMP_POLICY_FILE"

# Sync static site
echo "Syncing local files to S3..."
aws s3 sync ./site "$BUCKET_NAME_PATH" --delete

# Output next steps
if [[ "$DNS_PROVIDER" == "1" ]]; then
  echo "\n📘 Manual Step Required: Configure Route 53 DNS"
  echo "Refer to manual-steps/03-dns-route53.md"
else
  echo "\n📘 Manual Step Required: Configure Cloudflare DNS"
  echo "Refer to manual-steps/02-dns-cloudflare.md"
fi

echo "📘 Manual Step Required: Issue SSL Certificate"
echo "Refer to manual-steps/01-acm-certificate.md"

echo "✅ Static site deployed to: http://$BUCKET_NAME.s3-website-$(aws configure get region).amazonaws.com"
