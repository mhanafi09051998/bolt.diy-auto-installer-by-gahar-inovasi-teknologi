#!/bin/bash
set -e

echo "⚡ Installer Otomatis Bolt.DIY oleh Gahar Inovasi Teknologi"

# Minta domain
read -rp "🌐 Masukkan domain Anda (contoh: gaharinovasiteknologi.com): " DOMAIN
# Minta email
read -rp "📧 Masukkan email Anda (untuk menerima SSL & pemberitahuan): " USER_EMAIL
PORT=5173

if [[ -z "$DOMAIN" || -z "$USER_EMAIL" ]]; then
  echo "❌ Domain dan email wajib diisi. Proses dibatalkan."
  exit 1
fi

echo "📍 Domain: $DOMAIN"
echo "📨 Email: $USER_EMAIL"

# Update & instalasi paket dasar
sudo apt update
sudo apt install -y curl git nginx ca-certificates gnupg lsb-release software-properties-common mailutils mutt

# Node.js & pnpm
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
npm install -g pnpm

# Docker
sudo apt remove -y docker docker.io containerd runc || true
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Clone Bolt.DIY
git clone https://github.com/stackblitz-labs/bolt.diy.git || true
cd bolt.diy || exit 1

# Tambahkan allowedHosts
if ! grep -q "allowedHosts" vite.config.ts; then
  sed -i '/return {/a\
    server: {\
      host: true,\
      allowedHosts: ["'"$DOMAIN"'"],\
    },' vite.config.ts
fi

# Export default App
APP_FILE="src/App.tsx"
if [[ -f "$APP_FILE" ]] && ! grep -q "export default App" "$APP_FILE"; then
  echo -e "\nexport default App;" >> "$APP_FILE"
fi

# Install & build
pnpm install
pnpm run build

# Env untuk produksi
cat > .env.production <<EOF
PORT=$PORT
HOST=0.0.0.0
PUBLIC_URL=https://$DOMAIN
EOF

# Docker compose
cat > docker-compose.yml <<EOF
services:
  bolt:
    build: .
    container_name: bolt
    ports:
      - "$PORT:$PORT"
    env_file:
      - .env.production
    restart: always
EOF

# Jalankan container
sudo docker compose down || true
sudo docker compose up -d --build

# Nginx config
sudo tee /etc/nginx/sites-available/$DOMAIN > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://localhost:$PORT;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl reload nginx

# Certbot HTTPS
sudo apt install -y certbot python3-certbot-nginx

echo "🔐 Meminta sertifikat Let's Encrypt..."
if sudo test -f /etc/letsencrypt/live/$DOMAIN/fullchain.pem; then
  echo "✅ Sertifikat SSL untuk $DOMAIN sudah ada. Tidak membuat ulang."
else
  sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m "$USER_EMAIL"
fi

# Kirim sertifikat ke email
echo "📤 Mengirim sertifikat ke $USER_EMAIL..."
CERT_PATH="/etc/letsencrypt/live/$DOMAIN"
if [[ -d "$CERT_PATH" ]]; then
  (
    echo "Berikut adalah sertifikat SSL domain Anda ($DOMAIN). Simpan baik-baik untuk backup atau migrasi server ke depan.";
    echo "";
    echo "📄 Sertifikat: fullchain.pem"
    echo "🔐 Kunci Privat: privkey.pem"
  ) | mutt -s "SSL Certificate Backup for $DOMAIN" -a "$CERT_PATH/fullchain.pem" "$CERT_PATH/privkey.pem" -- "$USER_EMAIL"
  echo "✅ Sertifikat berhasil dikirim."
else
  echo "⚠️ Sertifikat tidak ditemukan. Pengiriman gagal."
fi

# Selesai
echo ""
echo "🎉 Instalasi selesai!"
echo "🌐 Akses di: https://$DOMAIN"
