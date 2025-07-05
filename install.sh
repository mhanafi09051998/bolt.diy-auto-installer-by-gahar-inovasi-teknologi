#!/bin/bash
set -e

echo "⚡ Installer Otomatis Bolt.DIY oleh Gahar Inovasi Teknologi"

# 1. Minta domain
read -rp "🌐 Masukkan domain Anda (contoh: gaharinovasiteknologi.com): " DOMAIN
# 2. Minta email untuk sertifikat
read -rp "📧 Masukkan email Anda untuk sertifikat SSL: " USER_EMAIL
PORT=5173

if [[ -z "$DOMAIN" || -z "$USER_EMAIL" ]]; then
  echo "❌ Domain dan email wajib diisi. Proses dibatalkan."
  exit 1
fi

echo "📍 Domain: $DOMAIN"
echo "📨 Email SSL: $USER_EMAIL"

# 3. Instalasi paket sistem dasar
echo "📦 Memasang paket sistem..."
sudo apt update
sudo apt install -y curl git nginx ca-certificates gnupg lsb-release software-properties-common

# 4. Instalasi Node.js & pnpm
echo "🧠 Memasang Node.js & pnpm..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
npm install -g pnpm

# 5. Instalasi Docker & Compose
echo "🐳 Memasang Docker & Docker Compose..."
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

# 6. Clone Bolt.DIY
echo "📥 Meng-clone repo Bolt.DIY..."
git clone https://github.com/stackblitz-labs/bolt.diy.git || true
cd bolt.diy || { echo "❌ Gagal masuk ke folder bolt.diy"; exit 1; }

# 7. Patch vite.config.ts
echo "🔧 Memodifikasi vite.config.ts..."
sed -i "s/config.mode !== 'test'/config.mode === 'development'/g" vite.config.ts
if ! grep -q "allowedHosts" vite.config.ts; then
  sed -i '/return {/a\
    server: {\
      host: true,\
      allowedHosts: ["'"$DOMAIN"'"],\
    },' vite.config.ts
fi

# 8. Pastikan App.tsx export default
APP_FILE="src/App.tsx"
if [[ -f "$APP_FILE" ]] && ! grep -q "export default App" "$APP_FILE"; then
  echo -e "\nexport default App;" >> "$APP_FILE"
fi

# 9. Install & build
echo "📦 Memasang dependensi & build..."
pnpm install
pnpm run build

# 10. Buat .env.production
cat > .env.production <<EOF
PORT=$PORT
HOST=0.0.0.0
PUBLIC_URL=https://$DOMAIN
EOF

# 11. Buat docker-compose.yml
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

# 12. Jalankan container
echo "🚀 Menjalankan container Docker..."
sudo docker compose down || true
sudo docker compose up -d --build

# 13. Konfigurasi Nginx
echo "🔁 Mengatur Nginx reverse proxy..."
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

# 14. Pasang Certbot & HTTPS
echo "🔐 Memasang sertifikat SSL via Let's Encrypt..."
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx \
  --non-interactive \
  --agree-tos \
  --email "$USER_EMAIL" \
  -d "$DOMAIN"

# 15. Selesai
echo ""
echo "✅ Instalasi selesai! Bolt.DIY berjalan di:"
echo "🌐 https://$DOMAIN"
