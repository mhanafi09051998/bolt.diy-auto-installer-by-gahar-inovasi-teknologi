#!/usr/bin/env bash

# install.sh - Instalasi Ollama Web GUI (bundled) dengan Docker dan konfigurasi SSL Let's Encrypt melalui Nginx
# Penggunaan: sudo bash install.sh

set -euo pipefail

# 0. Meminta input domain dan email
read -rp "Masukkan domain Anda (misal: gaharinovasiteknologi.com): " DOMAIN
read -rp "Masukkan email untuk registrasi Let's Encrypt: " EMAIL

# Konstanta
WEBUI_IMAGE="ghcr.io/open-webui/open-webui:ollama"  # Open WebUI yang sudah dibundel dengan Ollama
CONTAINER_NAME="open-webui"
HOST_PORT=3000
CONTAINER_PORT=8080
NGINX_CONF="/etc/nginx/sites-available/${DOMAIN}.conf"

# 1. Update & instalasi dependensi
echo "[*] Memperbarui sistem dan menginstal paket yang dibutuhkan..."
apt-get update && apt-get upgrade -y
apt-get install -y docker.io nginx certbot python3-certbot-nginx

# 2. Aktifkan dan mulai Docker & Nginx
echo "[*] Mengaktifkan dan memulai layanan Docker & Nginx..."
systemctl enable docker.service nginx.service
systemctl start docker.service nginx.service

# 3. Jalankan Open WebUI (dengan Ollama) di Docker
echo "[*] Menarik image Docker Open WebUI..."
docker pull ${WEBUI_IMAGE}

echo "[*] Menjalankan container Open-WebUI..."
docker rm -f ${CONTAINER_NAME} >/dev/null 2>&1 || true
docker run -d \
  --name ${CONTAINER_NAME} \
  --restart unless-stopped \
  -p 127.0.0.1:${HOST_PORT}:${CONTAINER_PORT} \
  ${WEBUI_IMAGE}

# 4. Konfigurasi Nginx sebagai reverse proxy
echo "[*] Menulis konfigurasi Nginx untuk ${DOMAIN}..."
cat > ${NGINX_CONF} <<EOF
server {
    listen 80;
    server_name ${DOMAIN};

    location / {
        proxy_pass http://127.0.0.1:${HOST_PORT};
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

echo "[*] Mengaktifkan konfigurasi situs dan me-reload Nginx..."
ln -sf ${NGINX_CONF} /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx

# 5. Mendapatkan dan menginstal sertifikat SSL dari Let's Encrypt
echo "[*] Mengambil sertifikat SSL Let's Encrypt untuk ${DOMAIN}..."
certbot --nginx --redirect -d ${DOMAIN} --non-interactive --agree-tos --email ${EMAIL}

# 6. Reload akhir Nginx
echo "[*] Me-reload Nginx dengan SSL..."
systemctl reload nginx

# 7. Ringkasan
cat <<EOF

Instalasi selesai! 🎉
- Open WebUI + Ollama berjalan di Docker pada localhost:${HOST_PORT}
- Dapat diakses di: https://${DOMAIN}/
- Sertifikat SSL dikelola otomatis oleh Let's Encrypt

EOF
