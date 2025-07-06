#!/bin/bash
# install.sh - Auto Install Bolt.diy on Ubuntu with SSL (manual input domain/email)
# Pastikan dijalankan sebagai root/sudo!

set -e

# --- Input manual domain dan email ---
echo "Masukkan domain yang akan digunakan (contoh: boltgahar1.my.id):"
read DOMAIN
echo "Masukkan email valid untuk SSL (Let's Encrypt):"
read EMAIL
BOLT_DIR="/opt/bolt.diy"

if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
  echo "Domain dan Email tidak boleh kosong! Keluar."
  exit 1
fi

# Update system
apt update && apt upgrade -y

# Install dependencies
apt install -y curl git nginx python3 python3-venv python3-pip certbot python3-certbot-nginx ufw

# Open firewall (jika UFW aktif)
ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw --force enable

# Clone Bolt.diy
if [ ! -d "$BOLT_DIR" ]; then
  git clone https://github.com/bolt-diy/bolt.diy.git "$BOLT_DIR"
fi
cd "$BOLT_DIR"

# Setup Python venv
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# (Opsional) Setup config Bolt.diy
cp -n .env.example .env

# Buat systemd service
cat <<EOF >/etc/systemd/system/bolt.diy.service
[Unit]
Description=Bolt.diy FastAPI Server
After=network.target

[Service]
User=root
WorkingDirectory=$BOLT_DIR
ExecStart=$BOLT_DIR/venv/bin/uvicorn app.main:app --host 127.0.0.1 --port 8000
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd & start service
systemctl daemon-reload
systemctl enable --now bolt.diy

# Setup Nginx config
cat <<EOF >/etc/nginx/sites-available/$DOMAIN
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Enable Nginx site
ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

# Install SSL
certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m $EMAIL --redirect

# Restart Nginx
systemctl reload nginx

echo "\n=== INSTALASI SELESAI ==="
echo "Akses https://$DOMAIN sudah siap dengan SSL."
