# 🧠 Bolt.DIY Installer Otomatis

Script **install.sh** ini memudahkan kamu untuk meng‑deploy aplikasi Bolt.DIY di Docker, sekaligus mengonfigurasi Nginx dan SSL Let's Encrypt secara otomatis. Hanya dengan beberapa baris perintah, website Bolt.DIY-mu langsung online dengan HTTPS! 🚀

---

## ✨ Fitur Utama

1. **Instalasi Dependensi Otomatis**  
   - Docker & Docker Compose  
   - Nginx + Certbot (Let's Encrypt)  
   - Node.js & PNPM  

2. **Setup Bolt.DIY**  
   - Clone repository resmi  
   - Patch `vite.config.ts` untuk host & allowedHosts  
   - Build aplikasi dengan PNPM  

3. **Konfigurasi Docker Compose**  
   - Membangun image lokal  
   - Container restart otomatis  

4. **Reverse Proxy & SSL**  
   - Konfigurasi Nginx untuk domain kustom  
   - HTTPS otomatis dengan Let's Encrypt + redirect HTTP→HTTPS  

---

## 🛠️ Prasyarat

- **Ubuntu Server** (20.04 / 22.04 / 24.04)  
- Akses **root** atau **sudo**  
- DNS _A record_ sudah mengarah ke IP server

---

## 🚀 Cara Penggunaan

1. **Clone repo**  
   ```bash
   git clone https://github.com/mhanafi09051998/bolt.diy-auto-installer-by-gahar-inovasi-teknologi-id
   cd boltdiy-installer
   chmod +x install.sh
