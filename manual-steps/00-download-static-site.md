# 00 - Download Static Website Files Using HTTrack

This step uses `httrack` to download a full copy of your live website to use as a static version hosted on S3.

---

## ✅ Requirements

Make sure `httrack` is installed on your Mac:

``` bash
brew install httrack
```
---

## 📥 How to Download Your Site
### Use the following command format:

``` bash
httrack "https://YOUR_DOMAIN.com" -O "./YOUR_OUTPUT_FOLDER" "+*.YOUR_DOMAIN.com/*" -v
```

### Example for rcaservices.net:
``` bash
httrack "https://rcaservices.net" -O "./rcaservices-static" "+*.rcaservices.net/*" -v
-O specifies the output directory.

"+*.rcaservices.net/*" ensures that only content from your own domain is included.

-v enables verbose logging.
```

## 🔄 After Downloading
Manually inspect the contents of the ./rcaservices-static folder.

Copy the contents into the site/ folder in your s3-static-site-deployer repo:

``` bash
cp -R ./rcaservices-static/* ./s3-static-site-deployer/site/
You’re now ready to run the deployment script:
```
``` bash
cd s3-static-site-deployer
./deploy.sh
```