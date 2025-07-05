# ⚡ Bolt.DIY Auto Installer for Ubuntu

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Vite Powered](https://img.shields.io/badge/Built%20with-Vite-blue)](https://vitejs.dev/)
[![Dockerized](https://img.shields.io/badge/Containerized-Docker-green)](https://www.docker.com/)

Skrip ini akan **menginstal dan mengkonfigurasi Bolt.DIY secara otomatis** di VPS Ubuntu dalam mode produksi hanya dengan 1 perintah.

✅ Fitur Utama:
- Instalasi Docker, Nginx, dan Certbot otomatis  
- Clone dan build Bolt.DIY langsung dari GitHub  
- Konfigurasi `vite.config.ts` agar domain publik tidak diblok  
- Reverse proxy via Nginx + HTTPS otomatis  
- Siap digunakan di domain Anda sendiri  

---

## 🚀 Cara Menggunakan

### 📌 Opsi 1 — Jalankan dari File Lokal

1. Upload `install.sh` ke VPS
2. Jadikan executable:

   ```bash
   chmod +x install.sh
