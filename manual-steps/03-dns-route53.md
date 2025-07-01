Here is the complete content for `manual-steps/03-dns-route53.md`:

---

### 📄 `manual-steps/03-dns-route53.md`

```markdown
# Manual Step: Connect Your Domain to S3 via Route 53

This guide walks you through connecting your custom domain to an S3 static site (or CloudFront distribution) using **AWS Route 53**.

---

## ✅ Step 1: Open the Route 53 Console

Go to [https://console.aws.amazon.com/route53/](https://console.aws.amazon.com/route53/)  
Click on **Hosted Zones** and select your domain (e.g., `example.com`).

---

## ✅ Step 2: Add a Record for the Root Domain

Click **Create Record**.

### Option 1: If using CloudFront

```

Record name: (leave blank for root domain)
Record type: A
Alias: Yes
Alias target: your CloudFront domain (e.g., d1234abcd.cloudfront.net)
Routing policy: Simple

```

Click **Create records**.

### Option 2: If using S3 website endpoint directly (not CloudFront)

> ❗ Important: You can only use alias records for **S3 website endpoints**, not the regular S3 REST API endpoint.

Find your static hosting endpoint for your region:
```

http\://<bucket-name>.s3-website-<region>.amazonaws.com

```

Then create:

```

Record name: (leave blank)
Type: A
Alias: Yes
Alias target: Select from S3 Website Endpoints list
Routing policy: Simple

```

Click **Create records**.

---

## ✅ Step 3: Add a Record for `www` (Optional)

If your users may visit `www.example.com`, repeat the process:

```

Record name: www
Type: A
Alias: Yes
Alias target: CloudFront or S3 endpoint (same as above)

```

You can also add a redirect from `www` to root or vice versa using S3 redirect bucket setup or CloudFront behaviors.

---

## ✅ Step 4: Wait for Propagation

Changes in Route 53 typically propagate within **minutes**, but may take up to an hour.

---

## ✅ Step 5: Test Your Website

Open your browser and visit:

```

[https://example.com](https://example.com)

```

✅ Your site should load correctly and securely.

---

## 🔒 Final Notes

- If using ACM for SSL, make sure the certificate is **validated and attached** to the CloudFront distribution.
- Route 53 alias records **do not count against your DNS query limits** and are free within AWS.
```


