Here is the full content for the file `manual-steps/01-acm-certificate.md`:

---

### 📄 `manual-steps/01-acm-certificate.md`

```markdown
# Manual Step: Create and Validate SSL Certificate via AWS ACM

This guide walks you through manually creating and validating an SSL certificate for your static website using **AWS Certificate Manager (ACM)**.

---

## ✅ Step 1: Open AWS ACM Console

Go to: [https://console.aws.amazon.com/acm/home](https://console.aws.amazon.com/acm/home)

Click **“Request a certificate”**.

---

## ✅ Step 2: Choose Public Certificate

Select:

```

✔️ Request a public certificate

```

Click **Next**.

---

## ✅ Step 3: Add Your Domain

Add the **primary domain** you plan to use (e.g., `example.com`).

You may also want to add a wildcard:

```

example.com
\*.example.com

```

Click **Next**.

---

## ✅ Step 4: Choose Validation Method

Choose:

```

✔️ DNS Validation - Recommended

```

Click **Next**.

---

## ✅ Step 5: Add Tags (Optional)

Tags are optional. Click **Next**.

---

## ✅ Step 6: Review and Request

Review your domain names and click **Request**.

---

## ✅ Step 7: Add DNS Records

For each domain, click **"Create records in Route 53"** if using Route 53.

If you're **not using Route 53**, copy the DNS record name and value for manual entry in your DNS provider (e.g., Cloudflare or GoDaddy).

Example record:
```

Name: \_123456abcdef.example.com
Type: CNAME
Value: \_abcde.acm-validations.aws.

```

Create this **CNAME record** exactly as shown in your DNS provider.

---

## ✅ Step 8: Wait for Validation

The ACM console will show a status of `Pending validation`.

Once DNS is correctly configured, it may take **a few minutes to several hours** for the certificate to be issued.

You’ll see the status change to:

```

✔️ Issued

```

---

## 🔐 Important Notes

- ACM certificates are free but can only be used **with AWS services** (e.g., CloudFront, Load Balancer).
- Certificates are valid for 13 months and will auto-renew if DNS records remain unchanged.

---

## ✅ Next Step

After the certificate is **issued**, return to the script or CloudFront configuration to attach the SSL certificate to your domain.

```


