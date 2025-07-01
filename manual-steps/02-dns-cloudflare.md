Here is the complete content for `manual-steps/02-dns-cloudflare.md`:

---

### 📄 `manual-steps/02-dns-cloudflare.md`

```markdown
# Manual Step: Connect Your Domain to S3 via Cloudflare DNS

This guide walks you through connecting your custom domain to an S3 static website using **Cloudflare** as your DNS provider.

---

## ✅ Step 1: Log in to Cloudflare

Visit [https://dash.cloudflare.com](https://dash.cloudflare.com) and log in.

Select your domain from the list (e.g., `example.com`).

---

## ✅ Step 2: Add S3 Static Website Record

Navigate to the **DNS** tab.

Click **“Add record”**, and create the following:

### A. For Root Domain (`example.com`)
```

Type: A
Name: @
IPv4 address: 192.0.2.1  ❌ \[DO NOT USE]

```
> ❗ S3 website endpoints don’t have static IPs. Use a **CNAME setup via Page Rule or Cloudflare Redirect**, or skip to the `www` subdomain method.

### B. For Subdomain (`www.example.com`)
Use this instead:
```

Type: CNAME
Name: www
Target: <your-s3-website-endpoint>
e.g., rcaservices.net.s3-website-us-east-1.amazonaws.com
TTL: Auto
Proxy status: DNS only (grey cloud)

```

Click **Save**.

---

## ✅ Step 3: Redirect Root Domain to `www`

If you want all `example.com` traffic to go to `www.example.com`:

1. Go to the **Page Rules** tab.
2. Click **Create Page Rule**.
3. Use this pattern:
```

[http://example.com/](http://example.com/)\*

```
4. Forward to:
```

[https://www.example.com/\$1](https://www.example.com/$1)

```
5. Set status code to `301 - Permanent Redirect`.
6. Save and deploy the rule.

---

## ✅ Step 4: Enable SSL (Optional but Recommended)

1. Go to the **SSL/TLS** tab.
2. Set **SSL Mode** to:
```

Full or Full (Strict)

```
3. Enable **Always Use HTTPS**.

This ensures that visitors are always redirected to the secure HTTPS version of your site.

---

## ✅ Step 5: Test Your Domain

Open your browser and go to:

```

[https://www.example.com](https://www.example.com)

```

✅ You should see your S3-hosted website loading via Cloudflare.

---

## 🔒 Optional: Use Cloudflare SSL

Cloudflare provides a free Universal SSL certificate. You don’t need to set up ACM if **Cloudflare is handling HTTPS**. If you’re using CloudFront, stick with ACM and keep Cloudflare in DNS-only mode.

---

## 📝 Notes

- Propagation of DNS changes may take a few minutes.
- Cloudflare's "proxy" (orange cloud) should be **off** if you're using CloudFront + ACM.
- If only using S3 website endpoints (no CloudFront), you can safely **enable proxying** for HTTPS with Cloudflare’s Universal SSL.

```


