#!/bin/bash
set -e

echo "⚡️ Bolt.DIY Auto Installer for Ubuntu VPS"

# ----------- TANYA DOMAIN ----------
read -rp "🌐 Masukkan domain Anda (sudah terhubung ke IP VPS): " DOMAIN
PORT=5173
EMAIL="admin@$DOMAIN"

if [[ -z "$DOMAIN" ]]; then
  echo "❌ Domain tidak boleh kosong. Coba lagi!"
  exit 1
fi

echo "📍 Domain yang akan digunakan: $DOMAIN"
sleep 1

# ----------- INSTALL DEPENDENSI ----------
echo "📦 Menginstal dependensi sistem..."
sudo apt update
sudo apt remove -y docker docker.io containerd runc || true
sudo apt install -y git nginx curl certbot python3-certbot-nginx ca-certificates gnupg lsb-release

# Setup Docker repository
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# ----------- CLONE BOLT.DIY ----------
echo "📥 Meng-clone repo Bolt.DIY..."
git clone https://github.com/stackblitz-labs/bolt.diy.git || true
cd bolt.diy

# ----------- PATCH VITE.CONFIG.TS ----------
echo "🔧 Menambahkan allowedHosts di vite.config.ts..."
if grep -q "allowedHosts" vite.config.ts; then
  echo "✅ Konfigurasi sudah ada"
else
  sed -i '/server: {/a\      allowedHosts: ['"'"$DOMAIN"'"'],' vite.config.ts
  sed -i '/server: {/a\      host: true,' vite.config.ts
fi

# ----------- ENV FILE ----------
echo "⚙️ Membuat .env.production..."
cat > .env.production <<EOF
PORT=$PORT
HOST=0.0.0.0
PUBLIC_URL=https://$DOMAIN
EOF

# ----------- DOCKER COMPOSE ----------
echo "🐳 Membuat docker-compose.yml..."
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

# ----------- JALANKAN DOCKER ----------
echo "🚀 Menjalankan Docker container..."
sudo docker compose down || true
sudo docker compose up -d --build

# ----------- KONFIGURASI NGINX ----------
echo "🔁 Menyiapkan reverse proxy Nginx..."
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
sudo nginx -t
sudo systemctl reload nginx

# ----------- AKTIFKAN HTTPS ----------
echo "🔐 Mengaktifkan HTTPS melalui Let's Encrypt..."
sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m $EMAIL --redirect

# ----------- DONE ----------
echo ""
echo "✅ Instalasi Bolt.DIY berhasil!"
echo "🌍 Akses sekarang: https://$DOMAIN"
