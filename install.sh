#!/bin/bash
set -e

echo "⚡️ Instalasi Otomatis Bolt.DIY untuk VPS Ubuntu oleh Gahar Inovasi Teknologi"

# --- Minta pengguna memasukkan nama domain ---
read -rp "🌐 Masukkan nama domain Anda (yang sudah diarahkan ke IP VPS ini): " DOMAIN
PORT=5173
EMAIL="admin@$DOMAIN"

if [[ -z "$DOMAIN" ]]; then
  echo "❌ Domain wajib diisi. Proses dibatalkan!"
  exit 1
fi

echo "📍 Menggunakan domain: $DOMAIN"
sleep 1

# --- Update sistem dan pasang dependensi utama ---
echo "📦 Memasang dependensi sistem..."
sudo apt update
sudo apt install -y curl git nginx certbot python3-certbot-nginx ca-certificates gnupg lsb-release

# --- Pasang Node.js versi terbaru (LTS 20) ---
echo "🧠 Memasang Node.js LTS..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# --- Pasang pnpm (pengganti npm yang lebih cepat) ---
echo "🧶 Memasang pnpm..."
npm install -g pnpm

# --- Pasang Docker & Docker Compose ---
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

# --- Clone repo Bolt.DIY ---
echo "📥 Mengunduh repo Bolt.DIY..."
git clone https://github.com/stackblitz-labs/bolt.diy.git || true
cd bolt.diy

# --- Edit vite.config.ts agar domain diizinkan ---
echo "🔧 Menyesuaikan vite.config.ts..."
if grep -q "allowedHosts" vite.config.ts; then
  echo "✅ Domain sudah ditambahkan sebelumnya"
else
  sed -i '/server: {/a\      allowedHosts: ['"'"$DOMAIN"'"'],' vite.config.ts
  sed -i '/server: {/a\      host: true,' vite.config.ts
fi

# --- Pastikan App.tsx punya export default ---
APP_FILE="src/App.tsx"
if [[ -f "$APP_FILE" ]] && ! grep -q "export default App" "$APP_FILE"; then
  echo "🛠️ Menambahkan 'export default App;' ke App.tsx..."
  echo -e "\nexport default App;" >> "$APP_FILE"
fi

# --- Install dependensi proyek ---
echo "📦 Memasang dependensi Node.js menggunakan pnpm..."
pnpm install

# --- Build aplikasi ---
echo "🔨 Membangun aplikasi..."
pnpm run build

# --- Buat file .env.production ---
echo "📝 Membuat file .env.production..."
cat > .env.production <<EOF
PORT=$PORT
HOST=0.0.0.0
PUBLIC_URL=https://$DOMAIN
EOF

# --- Buat file docker-compose.yml ---
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

# --- Jalankan container docker ---
echo "🚀 Menjalankan container Bolt..."
sudo docker compose down || true
sudo docker compose up -d --build

# --- Konfigurasi reverse proxy Nginx ---
echo "🔁 Mengatur reverse proxy Nginx..."
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

# --- Aktifkan HTTPS dengan Let's Encrypt ---
echo "🔐 Mengaktifkan HTTPS (SSL) dengan Let's Encrypt..."
sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m $EMAIL --redirect

# --- SELESAI ---
echo ""
echo "✅ Instalasi Bolt.DIY berhasil!"
echo "🌐 Akses melalui: https://$DOMAIN"
