#!/bin/bash
set -e

echo "⚡️ Instalasi Otomatis Bolt.DIY oleh Gahar Inovasi Teknologi"

# --- Minta domain dari user ---
read -rp "🌐 Masukkan domain Anda (contoh: bolt.domainanda.com): " DOMAIN
PORT=5173
EMAIL="admin@$DOMAIN"

if [[ -z "$DOMAIN" ]]; then
  echo "❌ Domain wajib diisi. Proses dibatalkan!"
  exit 1
fi

echo "📍 Domain yang digunakan: $DOMAIN"

# --- Update dan install dependensi sistem ---
echo "📦 Memasang dependensi..."
sudo apt update
sudo apt install -y curl git nginx certbot python3-certbot-nginx ca-certificates gnupg lsb-release

# --- Node.js LTS ---
echo "🧠 Memasang Node.js LTS..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# --- Install pnpm ---
echo "🧶 Memasang pnpm..."
npm install -g pnpm

# --- Install Docker ---
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

# --- Clone Bolt.DIY ---
echo "📥 Clone repo bolt.diy..."
git clone https://github.com/stackblitz-labs/bolt.diy.git || true

cd bolt.diy || { echo "❌ Gagal masuk ke folder bolt.diy"; exit 1; }

# --- Patch vite.config.ts ---
echo "🔧 Patch vite.config.ts untuk production..."
sed -i "s/config.mode !== 'test'/config.mode === 'development'/g" vite.config.ts

# Tambahkan allowedHosts dan host ke server config jika belum ada
if grep -q "allowedHosts" vite.config.ts; then
  echo "✅ Domain sudah ada di vite.config.ts"
else
  sed -i '/server: {/a\      allowedHosts: ['"'"$DOMAIN"'"'],' vite.config.ts
  sed -i '/server: {/a\      host: true,' vite.config.ts
fi

# Tambah "export default App;" kalau belum ada
APP_FILE="src/App.tsx"
if [[ -f "$APP_FILE" ]] && ! grep -q "export default App" "$APP_FILE"; then
  echo -e "\nexport default App;" >> "$APP_FILE"
fi

# --- Install dependencies & build ---
echo "📦 Install dependencies dan build..."
pnpm install
pnpm run build

# --- .env.production ---
echo "📝 Membuat .env.production..."
cat > .env.production <<EOF
PORT=$PORT
HOST=0.0.0.0
PUBLIC_URL=https://$DOMAIN
EOF

# --- Docker Compose ---
echo "⚙️ Membuat docker-compose.yml..."
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

# --- Jalankan Docker ---
echo "🚀 Menjalankan container Bolt..."
sudo docker compose down || true
sudo docker compose up -d --build

# --- Nginx reverse proxy ---
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
sudo nginx -t
sudo systemctl reload nginx

# --- SSL Let's Encrypt ---
echo "🔐 Mengaktifkan HTTPS dengan Let's Encrypt..."
sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m $EMAIL --redirect

# --- SELESAI ---
echo ""
echo "✅ Instalasi selesai! Bolt.DIY bisa diakses di:"
echo "🌐 https://$DOMAIN"
