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

> 💡 Pastikan domain Anda sudah mengarah ke IP VPS!

1. **Upload `install.sh` ke VPS Anda**
2. Jadikan executable:

   ```bash
   chmod +x install.sh
   sudo ./install.sh domainanda.my.id
