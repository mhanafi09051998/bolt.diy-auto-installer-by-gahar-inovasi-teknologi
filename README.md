
# ⚡ Bolt.DIY Auto Installer by Gahar Inovasi Teknologi ID

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Build Bolt DIY](https://img.shields.io/badge/Bolt.DIY-Production%20Ready-blue)](https://github.com/stackblitz-labs/bolt.diy)

🚀 Skrip `install.sh` ini akan secara otomatis menginstal [Bolt.DIY](https://github.com/stackblitz-labs/bolt.diy) di VPS Ubuntu Anda **dengan konfigurasi penuh**:

- ✅ Install Docker + Docker Compose
- ✅ Clone & Build Bolt.DIY
- ✅ Fix `vite.config.ts` agar domain publik bisa diakses
- ✅ Setup Nginx reverse proxy
- ✅ Aktifkan HTTPS via Let's Encrypt
- ✅ Jalankan langsung dalam production mode

---

## 🚀 Cara Cepat Menggunakan

```bash
# 1. Clone repo ini
git clone https://github.com/mhanafi09051998/bolt.diy-auto-installer-by-gahar-inovasi-teknologi-id.git
cd bolt.diy-auto-installer-by-gahar-inovasi-teknologi-id

# 2. Jadikan installer executable
chmod +x install.sh

# 3. Jalankan installer
sudo ./install.sh
```

> 💡 Saat dijalankan, Anda akan diminta memasukkan nama domain (misal: `boltgahar.my.id`).

---

## 🌍 Hasil Akhir

Setelah selesai, Anda bisa langsung akses Bolt.DIY melalui:

```
https://namadomainanda.com
```

---

## 📁 Struktur Proyek

```bash
.
├── install.sh              # Skrip installer otomatis
├── bolt.diy/               # Direktori hasil clone dari Bolt.DIY
│   ├── vite.config.ts      # Sudah dimodifikasi otomatis
│   └── docker-compose.yml  # Dihasilkan otomatis
```

---

## ❓ FAQ

**Q: Apa yang dibutuhkan sebelum menjalankan ini?**  
A: VPS Ubuntu (20.04/22.04), akses root, dan domain yang mengarah ke IP VPS Anda.

**Q: Port berapa yang digunakan Bolt?**  
A: Bolt jalan di port `5173`, tapi akan diakses lewat port `443` (HTTPS) via Nginx.

**Q: Apakah ini development mode?**  
A: Tidak. Ini langsung menjalankan dalam *production mode*.

**Q: Apakah subdomain juga bisa?**  
A: Ya, asalkan DNS sudah diarahkan.

---

## ❤️ Credits

Dibangun berdasarkan:
- [Bolt.DIY](https://github.com/stackblitz-labs/bolt.diy)
- [Docker](https://docker.com/)
- [Certbot](https://certbot.eff.org/)
- [Vite](https://vitejs.dev/)

---

## 📜 License

MIT License. Silakan gunakan & modifikasi bebas 🔥
