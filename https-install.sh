#!/bin/bash
set -e

echo "⚡ Installer Otomatis Bolt.DIY oleh Gahar Inovasi Teknologi"

# Meminta domain dari pengguna
read -rp "🌐 Masukkan domain Anda (contoh: bolt.domainkamu.com): " DOMAIN
PORT=5173
EMAIL="admin@$DOMAIN"

if [[ -z "$DOMAIN" ]]; then
  echo "❌ Domain wajib diisi. Proses dibatalkan."
  exit 1
fi

echo "📍 Menggunakan domain: $DOMAIN"

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

# Patch vite.config.ts agar aman di mode produksi
echo "🔧 Memodifikasi vite.config.ts..."
sed -i "s/config.mode !== 'test'/config.mode === 'development'/g" vite.config.ts

# Tambahkan allowedHosts dan host: true jika belum ada
echo "🌐 Menambahkan domain ke allowedHosts di vite.config.ts..."
if grep -q "allowedHosts" vite.config.ts; then
  echo "✅ allowedHosts sudah ada."
else
  sed -i '/server: {/a\      host: true,' vite.config.ts
  sed -i '/server: {/a\      allowedHosts: ['"'"$DOMAIN"'"'],' vite.config.ts
  echo "✅ Domain berhasil ditambahkan."
fi

# Tambahkan export default App jika belum ada
APP_FILE="src/App.tsx"
if [[ -f "$APP_FILE" ]] && ! grep -q "export default App" "$APP_FILE"; then
  echo "🛠️ Menambahkan 'export default App' ke App.tsx..."
  echo -e "\nexport default App;" >> "$APP_FILE"
fi

# Instal dependensi dan build
echo "📦 Memasang dependensi dan melakukan build..."
pnpm install
pnpm run build

# Membuat file .env.production
echo "📝 Membuat file .env.production..."
cat > .env.production <<EOF
PORT=$PORT
HOST=0.0.0.0
PUBLIC_URL=https://$DOMAIN
EOF

# Buat file docker-compose.yml
echo "⚙️ Membuat file docker-compose.yml..."
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

# Menjalankan container Docker
echo "🚀 Menjalankan container Bolt dengan Docker..."
sudo docker compose down || true
sudo docker compose up -d --build

# Konfigurasi Nginx reverse proxy
echo "🔁 Mengkonfigurasi Nginx untuk reverse proxy..."
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

# Aktifkan HTTPS dengan Let's Encrypt
echo "🔐 Mengaktifkan HTTPS dengan Let's Encrypt..."
sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m $EMAIL --redirect

# Selesai
echo ""
echo "✅ Instalasi selesai!"
echo "🌐 Akses aplikasi Anda di: https://$DOMAIN"
