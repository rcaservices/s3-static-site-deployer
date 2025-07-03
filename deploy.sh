#!/bin/bash

# deploy.sh

set -euo pipefail

REGION="us-east-1"

read -p "Enter a unique S3 bucket name (e.g., mysite-example-com): " BUCKET_NAME
read -p "Enter the full domain name (e.g., example.com): " DOMAIN_NAME

read -p $'Which DNS provider will you use?\n1) Route 53 (public access via S3 website)\n2) Cloudflare (private with CloudFront OAI)\nEnter 1 or 2: ' DNS_CHOICE

if [[ "$DNS_CHOICE" == "1" ]]; then
    POLICY_TEMPLATE="templates/bucket-policy-public.json"
    echo "🟢 You selected Route 53. Preparing bucket for public-read access."
else
    POLICY_TEMPLATE="templates/bucket-policy-oai.json"
    echo "🔒 You selected Cloudflare. Using CloudFront OAI for secure private access."
    read -p "Enter CloudFront OAI ID (e.g., E1234567890ABC): " OAI_ID

    echo "Fetching CanonicalUser ID for OAI..."
    CANONICAL_USER_ID=$(aws cloudfront get-cloud-front-origin-access-identity \
        --id "$OAI_ID" \
        --query 'CloudFrontOriginAccessIdentity.S3CanonicalUserId' \
        --output text)

    echo "Canonical User ID: $CANONICAL_USER_ID"
fi

echo "Creating bucket $BUCKET_NAME..."

if [ "$REGION" == "us-east-1" ]; then
    aws s3api create-bucket \
        --bucket "$BUCKET_NAME" \
        --region "$REGION" || true
else
    aws s3api create-bucket \
        --bucket "$BUCKET_NAME" \
        --region "$REGION" \
        --create-bucket-configuration LocationConstraint="$REGION" || true
fi

# ✅ Only disable Block Public Access settings if using Route 53 (public)
if [[ "$DNS_CHOICE" == "1" ]]; then
    echo "Disabling Block Public Access settings for $BUCKET_NAME..."
    aws s3api put-bucket-acl --bucket "$BUCKET_NAME" --acl public-read
    aws s3api delete-public-access-block --bucket "$BUCKET_NAME"
fi

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

S3_WEBSITE_URL="http://${DOMAIN_NAME}.s3-website-${REGION}.amazonaws.com"

echo ""
echo "✅ Deployment complete."
echo "------------------------------------------"
echo "Bucket Name   : $BUCKET_NAME"
echo "Domain Name   : $DOMAIN_NAME"
echo "Website URL   : $S3_WEBSITE_URL"
echo ""
echo "👉 Now follow the appropriate manual steps in ./manual-steps/ for SSL certificate and DNS configuration."
echo "------------------------------------------"
