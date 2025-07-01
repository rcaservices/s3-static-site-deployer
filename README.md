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
