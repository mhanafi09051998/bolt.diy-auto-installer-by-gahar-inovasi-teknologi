#!/bin/bash
set -e

# ----------- CONFIGURASI -----------
DOMAIN="$1"
PORT=5173
EMAIL="admin@$DOMAIN"

if [ -z "$DOMAIN" ]; then
  echo "❌ Harap berikan domain. Contoh: sudo ./install.sh boltgahar.my.id"
  exit 1
fi

echo "🌐 Domain yang digunakan: $DOMAIN"
sleep 1

# ----------- INSTALL DEPENDENSI ----------
echo "📦 Menginstal dependensi..."
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
echo "🧬 Meng-clone Bolt.DIY..."
git clone https://github.com/stackblitz-labs/bolt.diy.git || true
cd bolt.diy

# ----------- PATCH VITE.CONFIG.TS ----------
echo "🔧 Patch vite.config.ts untuk allowedHosts..."
if grep -q "allowedHosts" vite.config.ts; then
  echo "✅ allowedHosts sudah ada"
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
echo "📄 Membuat docker-compose.yml..."
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

# ----------- BUILD & RUN DOCKER ----------
echo "🐳 Build & run Bolt..."
sudo docker compose down || true
sudo docker compose up -d --build

# ----------- NGINX REVERSE PROXY ----------
echo "🔀 Menyiapkan Nginx reverse proxy..."
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

# ----------- HTTPS LET'S ENCRYPT ----------
echo "🔐 Mengaktifkan HTTPS dengan Certbot..."
sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m $EMAIL --redirect

# ----------- DONE ----------
echo ""
echo "✅ Bolt.DIY berhasil diinstal & dikonfigurasi!"
echo "🌐 Akses sekarang di: https://$DOMAIN"
