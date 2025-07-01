# S3 Static Site Deployer

This project automates the deployment of static websites to Amazon S3, sets up public website hosting, configures DNS via Route 53 or Cloudflare, and secures your site with HTTPS via ACM or Cloudflare SSL.

---

## 🧰 Features

- Automatically:
  - Syncs local website files to a new S3 bucket
  - Applies proper static website configuration
  - Makes files publicly readable
  - Configures SSL support (manual validation required)
- Supports:
  - AWS Route 53 for DNS setup
  - Cloudflare DNS (manual config)
- Provides:
  - `.md` documentation for any manual steps

---

## 📦 Usage

```bash
chmod +x deploy.sh
./deploy.sh
```
---

## 📁 Directory Layout
```bash
s3-static-site-deployer/
│
├── deploy.sh                   # Main Bash automation script
├── README.md                   # This file
├── templates/
│   └── bucket-policy.json      # JSON template for public S3 access
└── manual-steps/
    ├── 01-acm-certificate.md   # How to manually verify SSL cert
    ├── 02-dns-cloudflare.md    # DNS steps for Cloudflare
    └── 03-dns-route53.md       # DNS steps for Route 53
```

---

## ✅ Requirements

macOS or Linux with:

AWS CLI configured (aws configure)

jq, sed, curl installed

Permissions to:

Create S3 buckets

Configure Route 53 or Cloudflare (if selected)

Issue SSL certs with ACM or Let's Encrypt

---

🔐 Security Note
The script sets your S3 bucket policy to allow public read access for static hosting. Make sure that’s appropriate for your use case.

📖 License
Apache-2.0

## 🤝 Author
Built by Richard Asp for automating scalable static site deployments.


### 📂 `manual-steps/` markdown files

Each one contains full instructions:

#### ✅ `manual-steps/01-acm-certificate.md`
Instructions to issue and validate an SSL certificate using AWS Certificate Manager (ACM) via DNS.

#### ✅ `manual-steps/02-dns-cloudflare.md`
Steps to log into Cloudflare, add a CNAME or A record, and verify SSL if using their proxy and DNS.

#### ✅ `manual-steps/03-dns-route53.md`
Steps to create Route 53 A record alias to S3/CloudFront endpoint.

---







