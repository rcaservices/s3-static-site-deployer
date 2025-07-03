#!/bin/bash

# Exit on any error
set -e

# Prompt user for input
read -p "Enter a unique S3 bucket name (e.g., mysite-example-com): " BUCKET_NAME
read -p "Enter the full domain name (e.g., example.com): " DOMAIN_NAME

echo "Which DNS provider will you use?"
echo "1) Route 53"
echo "2) Cloudflare"
read -p "Enter 1 or 2: " DNS_PROVIDER

USE_OAI=false
if [ "$DNS_PROVIDER" == "2" ]; then
  USE_OAI=true
  echo "You selected Cloudflare. Using CloudFront OAI for secure delivery."
  read -p "Enter CloudFront OAI ID (e.g., E1234567890ABC): " OAI_ID

  echo "Fetching CanonicalUser ID for OAI..."
  FULL_OAI_PATH="origin-access-identity/cloudfront/${OAI_ID}"
  CANONICAL_USER_ID=$(aws cloudfront get-cloud-front-origin-access-identity \
    --id "$OAI_ID" \
    --query 'CloudFrontOriginAccessIdentity.S3CanonicalUserId' \
    --output text)
  echo "Canonical User ID: $CANONICAL_USER_ID"
fi

# Determine AWS region
AWS_REGION=$(aws configure get region)

# Create S3 bucket
echo "Creating bucket $BUCKET_NAME..."
if [ "$AWS_REGION" == "us-east-1" ]; then
  aws s3api create-bucket --bucket "$BUCKET_NAME"
else
  aws s3api create-bucket --bucket "$BUCKET_NAME" \
    --create-bucket-configuration LocationConstraint="$AWS_REGION"
fi

# Enable website hosting
echo "Configuring bucket for website hosting..."
aws s3 website s3://"$BUCKET_NAME"/ --index-document index.html --error-document 404.html || true

# Apply bucket policy
echo "Applying bucket policy..."
POLICY_TEMPLATE="templates/bucket-policy-"
if [ "$USE_OAI" = true ]; then
  POLICY_TEMPLATE+="oai.json"
  sed "s/BUCKET_NAME_PLACEHOLDER/$BUCKET_NAME/g; s/OAI_ID_PLACEHOLDER/$CANONICAL_USER_ID/g" "$POLICY_TEMPLATE" > temp-bucket-policy.json
else
  POLICY_TEMPLATE+="public.json"
  sed "s/BUCKET_NAME_PLACEHOLDER/$BUCKET_NAME/g" "$POLICY_TEMPLATE" > temp-bucket-policy.json
fi

aws s3api put-bucket-policy --bucket "$BUCKET_NAME" --policy file://temp-bucket-policy.json

# Upload website content
echo "Uploading website files from site/..."
aws s3 sync site/ s3://"$BUCKET_NAME"/ --delete

# Output final URLs and next steps
echo ""
echo "✅ Deployment complete."
echo "Website URL: http://$BUCKET_NAME.s3-website-$AWS_REGION.amazonaws.com"

if [ "$DNS_PROVIDER" == "1" ]; then
  echo "➡️  Now configure your Route 53 DNS settings:"
  echo "   See manual-steps/03-dns-route53.md"
else
  echo "➡️  Now configure your Cloudflare DNS and SSL settings:"
  echo "   See manual-steps/02-dns-cloudflare.md and 01-acm-certificate.md"
fi

echo "📝 Don't forget to verify SSL setup and connect the domain!"
