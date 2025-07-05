#!/bin/bash
set -e

echo "⚡ Installer Otomatis Bolt.DIY oleh Gahar Inovasi Teknologi"

# 1. Minta domain
read -rp "🌐 Masukkan domain Anda (contoh: gaharinovasiteknologi.com): " DOMAIN
PORT=5173

if [[ -z "$DOMAIN" ]]; then
  echo "❌ Domain wajib diisi. Proses dibatalkan."
  exit 1
fi

echo "📍 Domain: $DOMAIN"

# 2. Pasang paket sistem dasar
sudo apt update
sudo apt install -y curl git nginx ca-certificates gnupg lsb-release software-properties-common

# 3. Pasang Node.js LTS & pnpm
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
npm install -g pnpm

# 4. Pasang Docker & Compose
sudo apt remove -y docker docker.io containerd runc || true
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 5. Clone Bolt.DIY
git clone https://github.com/stackblitz-labs/bolt.diy.git || true
cd bolt.diy || { echo "❌ Gagal masuk ke folder bolt.diy"; exit 1; }

# 6. Patch vite.config.ts
sed -i "s/config.mode !== 'test'/config.mode === 'development'/g" vite.config.ts
if ! grep -q "allowedHosts" vite.config.ts; then
  sed -i '/return {/a\
    server: {\
      host: true,\
      allowedHosts: ["'"$DOMAIN"'"],\
    },' vite.config.ts
fi

# 7. Pastikan App.tsx export default
APP_FILE="src/App.tsx"
if [[ -f "$APP_FILE" ]] && ! grep -q "export default App" "$APP_FILE"; then
  echo -e "\nexport default App;" >> "$APP_FILE"
fi

# 8. Install & build
pnpm install
pnpm run build

# 9. .env.production
cat > .env.production <<EOF
PORT=$PORT
HOST=0.0.0.0
PUBLIC_URL=https://$DOMAIN
EOF

# 10. docker-compose.yml
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

# 11. Jalankan Container
sudo docker compose down || true
sudo docker compose up -d --build

# 12. Konfigurasi Nginx
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

# 13. Pasang Certbot & HTTPS
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos

# 14. Selesai
echo ""
echo "✅ Instalasi selesai! Bolt.DIY berjalan di:"
echo "🌐 https://$DOMAIN"
