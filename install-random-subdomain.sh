#!/bin/bash
set -e

echo "⚡ Installer Bolt.DIY Otomatis dengan Subdomain Acak oleh Gahar Inovasi Teknologi"

# Meminta domain utama dari pengguna
read -rp "🌐 Masukkan domain utama kamu (misal: boltgahar.my.id): " ROOT_DOMAIN
PORT=5173

if [[ -z "$ROOT_DOMAIN" ]]; then
  echo "❌ Domain wajib diisi. Proses dibatalkan."
  exit 1
fi

# Buat subdomain acak
RANDOM_SUFFIX=$((RANDOM % 1000))
SUBDOMAIN="demo-$RANDOM_SUFFIX"
DOMAIN="$SUBDOMAIN.$ROOT_DOMAIN"
EMAIL="admin@$ROOT_DOMAIN"

echo "📍 Menggunakan subdomain acak: $DOMAIN"

# Pastikan DNS A record sudah diarahkan ke IP VPS

# Instalasi dependensi sistem
echo "📦 Memasang paket sistem..."
sudo apt update
sudo apt install -y curl git nginx certbot python3-certbot-nginx ca-certificates gnupg lsb-release

# Instalasi Node.js
echo "🧠 Memasang Node.js versi LTS..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Instalasi pnpm
echo "🧶 Memasang pnpm..."
npm install -g pnpm

# Instalasi Docker
echo "🐳 Memasang Docker..."
sudo apt remove -y docker docker.io containerd runc || true
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Clone repo Bolt.DIY
echo "📥 Meng-clone repo Bolt.DIY..."
git clone https://github.com/stackblitz-labs/bolt.diy.git || true

cd bolt.diy || { echo "❌ Gagal masuk ke folder 'bolt.diy'. Proses dibatalkan."; exit 1; }

# Patch vite.config.ts
echo "🔧 Patch vite.config.ts..."
sed -i "s/config.mode !== 'test'/config.mode === 'development'/g" vite.config.ts

# Tambahkan allowedHosts dan host: true
echo "🌐 Menambahkan allowedHosts..."
if grep -q "allowedHosts" vite.config.ts; then
  echo "✅ allowedHosts sudah ada."
else
  sed -i '/server: {/a\      host: true,' vite.config.ts
  sed -i '/server: {/a\      allowedHosts: ['"'"$DOMAIN"'"'],' vite.config.ts
fi

# Tambahkan export default App
APP_FILE="src/App.tsx"
if [[ -f "$APP_FILE" ]] && ! grep -q "export default App" "$APP_FILE"; then
  echo "🛠️ Menambahkan 'export default App'..."
  echo -e "\nexport default App;" >> "$APP_FILE"
fi

# Install dan build
echo "📦 Memasang dependensi & build..."
pnpm install
pnpm run build

# File env
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

# Jalankan docker
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
sudo nginx -t
sudo systemctl reload nginx

# Let's Encrypt
echo "🔐 Mengaktifkan HTTPS via Let's Encrypt..."
sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m $EMAIL --redirect || {
  echo "⚠️ Gagal membuat sertifikat. Gunakan HTTP dulu di http://$DOMAIN"
}

echo ""
echo "✅ Instalasi selesai!"
echo "🌐 Akses aplikasi Anda di: https://$DOMAIN"
