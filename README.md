# 🚀 Installer Otomatis Bolt.DIY (Mode Produksi)

**Bolt.DIY** adalah antarmuka LLM berbasis web yang dikembangkan oleh [StackBlitz Labs](https://github.com/stackblitz-labs/bolt.diy).  
Proyek ini dibuat untuk memberikan UI ringan dan cepat bagi pengguna model LLM (seperti Ollama, OpenAI, LM Studio, dan lainnya).

🎯 Installer ini dirancang untuk digunakan di VPS (Ubuntu) dan langsung menjalankan Bolt.DIY secara **aman di mode produksi** (bukan development).

---

## 🔧 Fitur Installer

✅ Instalasi otomatis (Node.js, pnpm, Docker, Nginx)  
✅ Konfigurasi domain otomatis dengan Nginx  
✅ HTTPS dengan Let's Encrypt  
✅ Patch otomatis `vite.config.ts` agar tidak error  
✅ Otomatis export default App.tsx  
✅ Tanpa konfigurasi ulang manual

---

## ⚙️ Syarat VPS

- Sistem operasi: **Ubuntu 20.04/22.04**
- Akses `root`
- Domain aktif yang sudah mengarah ke IP VPS (misalnya dari Cloudflare atau DNS lain)

---

## 🚀 Cara Install

```bash
git clone https://github.com/mhanafi09051998/bolt.diy-auto-installer-by-gahar-inovasi-teknologi-id.git
cd bolt.diy-auto-installer-by-gahar-inovasi-teknologi-id
chmod +x install.sh
./install.sh
```

Setelah menjalankan perintah di atas, Anda akan diminta memasukkan domain Anda:  
Contoh: `bolt.namadomainkamu.com`

---

## 🌐 Akses Aplikasi

Setelah proses selesai, Anda dapat mengakses Bolt.DIY melalui:

```
https://namadomainkamu.com
```

---

## 📦 Dukungan LLM

Bolt.DIY dapat terhubung dengan berbagai model LLM lokal & cloud:

- [x] OpenAI
- [x] LM Studio
- [x] Ollama
- [x] Together AI
- [x] Groq
- [x] Model lainnya (dengan endpoint compatible)

---

## 🛡️ Keamanan

- Menggunakan HTTPS dari Let's Encrypt  
- Hanya mendengarkan dari domain Anda (diblokir jika bukan host yang diizinkan)  
- Dapat dikombinasikan dengan Cloudflare + WAF untuk keamanan maksimal

---

## 🙏 Kredit

- 💡 Proyek asli oleh [StackBlitz Labs - bolt.diy](https://github.com/stackblitz-labs/bolt.diy)
- 🔧 Diadaptasi & disederhanakan oleh [Gahar Inovasi Teknologi](https://github.com/mhanafi09051998)

---

## ❤️ Donasi / Dukungan

Jika Anda merasa terbantu oleh proyek ini, bantu kami dengan ⭐️ di GitHub, atau kopi virtual ☕ di link berikut:

> 📬 Saweria: https://saweria.co/gaharinovasi

---

## 📜 Lisensi

MIT License. Gunakan bebas untuk edukasi, riset, maupun produksi.
