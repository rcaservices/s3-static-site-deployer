#!/bin/bash

# === CONFIG PROMPT ===
echo "🟦 Starting Static Site Deployment"
echo
read -p "Enter domain name (e.g., example.com): " DOMAIN
read -p "Enter full path to your static site folder: " SITE_DIR
read -p "Enter AWS region (e.g., us-east-1): " REGION
echo "Choose DNS provider:"
select DNS_PROVIDER in "Route53" "Cloudflare"; do
    case $DNS_PROVIDER in
        Route53 ) break;;
        Cloudflare ) break;;
        * ) echo "Please select 1 or 2.";;
    esac
done

BUCKET_NAME=$DOMAIN

# === VALIDATION ===
if [ ! -d "$SITE_DIR" ]; then
  echo "❌ Directory does not exist: $SITE_DIR"
  exit 1
fi

# === CREATE BUCKET ===
echo "🪣 Creating S3 bucket: $BUCKET_NAME"
aws s3 mb s3://$BUCKET_NAME --region $REGION

# === CONFIGURE PUBLIC ACCESS ===
echo "🔓 Configuring public access"
aws s3api put-bucket-policy \
  --bucket $BUCKET_NAME \
  --policy file://templates/bucket-policy.json

aws s3 website s3://$BUCKET_NAME/ \
  --index-document index.html \
  --error-document 404.html

# === UPLOAD FILES ===
echo "📤 Uploading site files"
aws s3 sync "$SITE_DIR" s3://$BUCKET_NAME --delete

# === SSL CERTIFICATE ===
echo "🔐 Requesting SSL certificate"
CERT_ARN=$(aws acm request-certificate \
  --domain-name $DOMAIN \
  --validation-method DNS \
  --region us-east-1 \
  --query CertificateArn --output text)

echo "🔍 Certificate ARN: $CERT_ARN"

# === OUTPUT DNS Validation Instructions ===
cp manual-steps/01-acm-certificate.md dns-validation-$DOMAIN.md
sed -i '' "s/yourdomain.com/$DOMAIN/g" dns-validation-$DOMAIN.md

# === CREATE CLOUDFRONT ===
echo "🌐 Creating CloudFront distribution (this takes a few minutes...)"
CF_DIST_ID=$(aws cloudfront create-distribution \
  --origin-domain-name $BUCKET_NAME.s3-website-$REGION.amazonaws.com \
  --default-root-object index.html \
  --viewer-certificate ACMCertificateArn=$CERT_ARN,SSLSupportMethod=sni-only,MinimumProtocolVersion=TLSv1.2_2021 \
  --aliases Items=$DOMAIN \
  --query Distribution.Id --output text)

CF_DOMAIN=$(aws cloudfront get-distribution \
  --id $CF_DIST_ID \
  --query Distribution.DomainName --output text)

echo "✅ CloudFront Domain: $CF_DOMAIN"

# === FINAL DNS SETUP ===
case $DNS_PROVIDER in
    Route53)
        echo "📄 See: manual-steps/03-dns-route53.md"
        cp manual-steps/03-dns-route53.md dns-setup-$DOMAIN.md
        ;;
    Cloudflare)
        echo "📄 See: manual-steps/02-dns-cloudflare.md"
        cp manual-steps/02-dns-cloudflare.md dns-setup-$DOMAIN.md
        ;;
esac

# === DONE ===
echo "🎉 Deployment complete."
echo "👉 Visit: https://$DOMAIN (after DNS + cert validation)"
echo "📝 Manual steps saved in: dns-validation-$DOMAIN.md and dns-setup-$DOMAIN.md"
