```markdown
# ⚡ Bolt.DIY Auto Installer

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Build Bolt DIY](https://img.shields.io/badge/Bolt.DIY-Production%20Ready-blue)](https://github.com/stackblitz-labs/bolt.diy)

🚀 Skrip `install.sh` ini akan secara otomatis menginstal [Bolt.DIY](https://github.com/stackblitz-labs/bolt.diy) di VPS Ubuntu Anda **dengan konfigurasi penuh**:

- ✅ Auto install Docker + Docker Compose
- ✅ Clone & Build Bolt.DIY
- ✅ Fix `vite.config.ts` (allow domain publik)
- ✅ Nginx reverse proxy (port 5173)
- ✅ HTTPS otomatis via Let’s Encrypt
- ✅ Full production mode dalam 1 perintah!

---

## 🔧 Cara Instalasi

> 💡 Pastikan domain Anda sudah mengarah ke IP VPS Anda (menggunakan DNS A Record).

1. **Upload `install.sh` ke VPS Anda**
2. Jadikan executable:

   ```bash
   chmod +x install.sh
   ```

3. Jalankan:

   ```bash
   sudo ./install.sh
   ```

4. Masukkan domain Anda saat diminta, contoh:

   ```
   🌐 Masukkan domain Anda (sudah terhubung ke IP VPS): boltgahar.my.id
   ```

---

## 🌐 Hasil Akhir

Setelah selesai, Anda bisa langsung akses Bolt.DIY melalui:

```
https://namadomainanda.com
```

---

## 📁 Struktur Proyek

```bash
.
├── install.sh              # Skrip installer otomatis
├── bolt.diy/               # Direktori hasil clone repo Bolt.DIY
│   ├── vite.config.ts      # Sudah dimodifikasi untuk production host
│   └── docker-compose.yml  # Sudah di-generate otomatis
```

---

## ❓ FAQ

**Q: Port berapa yang digunakan Bolt?**  
A: Secara default menggunakan `5173`, lalu di-proxy melalui Nginx ke HTTPS port 443.

**Q: Apakah ini development mode?**  
A: Tidak. Skrip ini akan langsung menjalankan Bolt.DIY dalam *production mode*, siap pakai.

**Q: Apakah subdomain didukung?**  
A: Ya, asal DNS sudah diarahkan ke IP VPS.

---

## ❤️ Credits

Dibangun berdasarkan:
- [Bolt.DIY](https://github.com/stackblitz-labs/bolt.diy)
- [Vite](https://vitejs.dev/)
- [Docker](https://docker.com/)
- [Certbot](https://certbot.eff.org/)

---

## 📜 License

MIT License. Silakan gunakan dan modifikasi bebas 🔥
```
