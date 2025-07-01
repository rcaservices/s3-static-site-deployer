#!/bin/bash

set -e

# === CONFIGURATION ===
REGION="us-east-1"
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
TEMPLATES_DIR="$SCRIPT_DIR/templates"
MANUAL_STEPS_DIR="$SCRIPT_DIR/manual-steps"

# === INPUT PROMPTS ===
echo "Enter a unique S3 bucket name (e.g., mysite-example-com):"
read BUCKET_NAME

echo "Enter the full domain name (e.g., example.com):"
read DOMAIN_NAME

echo "Which DNS provider will you use?"
echo "1) Route 53"
echo "2) Cloudflare"
read -p "Enter 1 or 2: " DNS_CHOICE

if [[ "$DNS_CHOICE" == "1" ]]; then
  USE_CLOUDFRONT=false
  POLICY_FILE="$TEMPLATES_DIR/bucket-policy-public.json"
  echo "You selected Route 53. Using public-read bucket policy."
else
  USE_CLOUDFRONT=true
  POLICY_FILE="$TEMPLATES_DIR/bucket-policy-oai.json"
  echo "You selected Cloudflare. Using CloudFront OAI for secure delivery."
fi

# === CREATE S3 BUCKET ===
echo "Creating bucket $BUCKET_NAME..."
aws s3api create-bucket \
  --bucket "$BUCKET_NAME" \
  --region "$REGION" \
  --create-bucket-configuration LocationConstraint="$REGION" || true

# === CONFIGURE BUCKET POLICY ===
if [ "$USE_CLOUDFRONT" = true ]; then
  echo "Enter CloudFront OAI ID (e.g., E1234567890ABC):"
  read OAI_ID
  sed "s|OAI_ID_PLACEHOLDER|$OAI_ID|g; s|BUCKET_NAME_PLACEHOLDER|$BUCKET_NAME|g" "$POLICY_FILE" > temp-bucket-policy.json
else
  sed "s|BUCKET_NAME_PLACEHOLDER|$BUCKET_NAME|g" "$POLICY_FILE" > temp-bucket-policy.json
fi

aws s3api put-bucket-policy --bucket "$BUCKET_NAME" --policy file://temp-bucket-policy.json
rm temp-bucket-policy.json

# === ENABLE STATIC SITE HOSTING ===
echo "Configuring static website hosting..."
aws s3 website s3://$BUCKET_NAME/ --index-document index.html --error-document index.html

# === UPLOAD SITE FILES ===
echo "Uploading static site files..."
aws s3 sync . "s3://$BUCKET_NAME" --delete

# === NEXT STEPS ===
echo "✅ Website files uploaded."
if [ "$USE_CLOUDFRONT" = true ]; then
  echo "Please follow the manual setup in: $MANUAL_STEPS_DIR/01-acm-certificate.md"
  echo "Then see: $MANUAL_STEPS_DIR/02-dns-cloudflare.md"
else
  echo "Please follow the manual setup in: $MANUAL_STEPS_DIR/01-acm-certificate.md"
  echo "Then see: $MANUAL_STEPS_DIR/03-dns-route53.md"
fi
