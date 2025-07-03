#!/bin/bash

# deploy.sh

set -euo pipefail

read -p "Enter a unique S3 bucket name (e.g., mysite-example-com): " BUCKET_NAME
read -p "Enter the full domain name (e.g., example.com): " DOMAIN_NAME

read -p $'Which DNS provider will you use?\n1) Route 53\n2) Cloudflare\nEnter 1 or 2: ' DNS_CHOICE

if [[ "$DNS_CHOICE" == "1" ]]; then
    POLICY_TEMPLATE="templates/bucket-policy-public.json"
    echo "You selected Route 53. Using public-read policy."
else
    POLICY_TEMPLATE="templates/bucket-policy-oai.json"
    echo "You selected Cloudflare. Using CloudFront OAI for secure delivery."
    read -p "Enter CloudFront OAI ID (e.g., E1234567890ABC): " OAI_ID

    echo "Fetching CanonicalUser ID for OAI..."
    CANONICAL_USER_ID=$(aws cloudfront get-cloud-front-origin-access-identity \
        --id "$OAI_ID" \
        --query 'CloudFrontOriginAccessIdentity.S3CanonicalUserId' \
        --output text)

    echo "Canonical User ID: $CANONICAL_USER_ID"
fi

echo "Creating bucket $BUCKET_NAME..."
aws s3api create-bucket \
  --bucket "$BUCKET_NAME" \
  --region us-east-1 \
  --create-bucket-configuration LocationConstraint=us-east-1 || true

echo "Configuring bucket for website hosting..."
aws s3 website s3://"$BUCKET_NAME"/ \
  --index-document index.html \
  --error-document index.html

POLICY_FILE="temp-bucket-policy.json"

if [[ "$DNS_CHOICE" == "1" ]]; then
    sed "s/BUCKET_NAME_PLACEHOLDER/$BUCKET_NAME/g" "$POLICY_TEMPLATE" > "$POLICY_FILE"
else
    sed "s/BUCKET_NAME_PLACEHOLDER/$BUCKET_NAME/g; s/OAI_ID_PLACEHOLDER/$CANONICAL_USER_ID/g" "$POLICY_TEMPLATE" > "$POLICY_FILE"
fi

echo "Applying bucket policy..."
aws s3api put-bucket-policy \
  --bucket "$BUCKET_NAME" \
  --policy file://"$POLICY_FILE"

echo "Uploading files to S3..."
aws s3 sync site/ s3://"$BUCKET_NAME" --delete

echo "✅ Deployment complete."
echo "👉 Now follow the appropriate manual steps in ./manual-steps/ for SSL certificate and DNS configuration."
