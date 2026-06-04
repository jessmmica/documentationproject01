#!/bin/bash
set -e

# Download and install DITA-OT
DITA_OT_VERSION="4.2.1"
echo "Installing DITA-OT ${DITA_OT_VERSION}..."
wget -q "https://github.com/dita-ot/dita-ot/releases/download/${DITA_OT_VERSION}/dita-ot-${DITA_OT_VERSION}.zip" -O /tmp/dita-ot.zip
sudo unzip -q /tmp/dita-ot.zip -d /opt
sudo mv /opt/dita-ot-${DITA_OT_VERSION} /opt/dita-ot
sudo chmod +x /opt/dita-ot/bin/dita
rm /tmp/dita-ot.zip

echo "✅ DITA-OT installed at /opt/dita-ot"