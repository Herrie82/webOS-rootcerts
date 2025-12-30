# Rebuild CA certificate bundle from modern certificates
echo "Updating CA certificate bundle ..."
if [ -d /etc/ssl/certs/trustedcerts ]; then
    # Backup old certificate bundle
    if [ -f /etc/ssl/certs/ca-certificates.crt ]; then
        cp /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt.old
        echo "  Backed up old ca-certificates.crt"
    fi

    # Create new bundle from all PEM files in trustedcerts
    cd /etc/ssl/certs/trustedcerts
    cat *.pem > /etc/ssl/certs/ca-certificates.crt.new
    mv /etc/ssl/certs/ca-certificates.crt.new /etc/ssl/certs/ca-certificates.crt

    cert_count=$(ls -1 *.pem 2>/dev/null | wc -l)
    echo "  ✓ Rebuilt ca-certificates.crt from ${cert_count} certificates"
else
    echo "  WARNING: /etc/ssl/certs/trustedcerts not found, skipping"
fi

