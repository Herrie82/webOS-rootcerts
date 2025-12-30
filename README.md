# webOS Root Certificates Update

## Package Information

**New Package:** `com.palm_.rootcertsupdate_1.0-4_all.ipk`
**Updated:** 2025-12-28
**Certificate Bundle:** Mozilla CA bundle from December 2, 2025
**Certificate Count:** 144 certificates (down from 197 in 2015 version)

## Changes from Original Package

### Version 1.0-4 (RECOMMENDED)
- **Fixed postinst script** to properly handle webOS 3.x installation
- Creates `/var/ssl/trustedcerts` if it doesn't exist during installation
- Updated 144 modern root certificates from Mozilla CA bundle (2025-12-02)
- All certificate formats updated:
  - `ca-certificates.crt` (220KB)
  - `system-bundle.crt.gz` (126KB)
  - `root-certs.tar.gz` (129KB with 144 individual .pem files)

### Version 1.0-3 (DO NOT USE)
- Had installation bug - would fail on webOS 3.x

### Original Version 1.0-2 (2015)
- 197 certificates from 2015
- Many expired or untrusted certificates included

## Installation Issue Fixed

### The Problem
The original postinst script checked for both directories to exist:
```bash
if [ -d /etc/ssl/certs/trustedcerts ] && [ -d /var/ssl/trustedcerts ]; then
```

On webOS 3.0.5:
- `/etc/ssl/certs/trustedcerts/` exists (permanent storage)
- `/var/ssl/trustedcerts/` is created at boot time, might not exist during IPK installation

This caused installation to fail with "cannot find scripts directory" error.

### The Fix
Modified postinst script to:
1. Check only if `/etc/ssl/certs/trustedcerts` exists
2. Create `/var/ssl/trustedcerts` if it doesn't exist
3. Proceed with certificate deployment using `deploycerts.sh`

## Certificate Manager

After installation, certificates should appear in the webOS certificate manager at:
- Location: `/var/ssl/trustedcerts/` (symlinks)
- Permanent storage: `/etc/ssl/certs/trustedcerts/` (actual certificate files)

The `deploycerts.sh` script will:
1. Extract certificates from `root-certs.tar.gz`
2. Move them to `/etc/ssl/certs/trustedcerts/`
3. Create hash-based symlinks (e.g., `a94d09af.0` -> `ACCVRAIZ1.pem`)
4. Update `/var/ssl/trustedcerts/` with symlinks

## Known Issues

### CRL Download Error (Separate Issue)
You may still see this error in logs:
```
luna-send: http://crl.palm-contentid.pp.trustcenter.de/crl/v2/palmcontentid-CA-I.crl
```

This is **NOT** related to the root certificates package. It's from:
- **File:** `/etc/event.d/certstoreinit` line 34
- **Purpose:** Downloads Certificate Revocation List for webOS app signing
- **Issue:** Server has been dead since Palm/HP discontinued webOS

This CRL is used with the WebOSRoot certificate for app signing, not for general SSL/TLS.

### To fix the CRL error (optional):
Comment out line 34 in `/etc/event.d/certstoreinit`:
```bash
# luna-send -n 1 luna://com.palm.certificatemanager/addcrl '{"url":"http://crl.palm-contentid.pp.trustcenter.de/crl/v2/palmcontentid-CA-I.crl"}'
```

## Installation Instructions

1. Copy `com.palm_.rootcertsupdate_1.0-4_all.ipk` to your webOS device
2. Install via command line:
   ```bash
   opkg install com.palm_.rootcertsupdate_1.0-4_all.ipk
   ```
3. Monitor installation output for "Root certs successfully updated"
4. Check certificate manager to verify certificates are listed

## Verification

After installation, verify:
```bash
ls -l /etc/ssl/certs/trustedcerts/ | wc -l  # Should show many certificates
ls -l /var/ssl/trustedcerts/ | wc -l        # Should show symlinks
```

## Files Included

- `com.palm_.rootcertsupdate_1.0-2_all.ipk` - Original 2015 package (967KB)
- `com.palm_.rootcertsupdate_1.0-3_all.ipk` - Broken version (DO NOT USE)
- `com.palm_.rootcertsupdate_1.0-4_all.ipk` - **FIXED VERSION** (386KB)
- `cacert-2025.pem` - Source Mozilla CA bundle
- `ipk_extract/` - Unpacked package for reference

## Credits

- Original package by frantid (webOS forums)
- Certificate bundle from Mozilla NSS / curl.se
- Updated and fixed for webOS 3.0.5 compatibility
