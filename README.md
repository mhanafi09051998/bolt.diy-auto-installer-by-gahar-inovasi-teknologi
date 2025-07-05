# ⚡ Auto Installer Bolt.DIY oleh Gahar Inovasi Teknologi 🇮🇩

Installer otomatis dan siap produksi untuk [Bolt.DIY](https://github.com/stackblitz-labs/bolt.diy) — antarmuka LLM open source dari StackBlitz.  
Script ini mempermudah proses instalasi Bolt.DIY di VPS Ubuntu hanya dalam beberapa menit, menggunakan domain Anda sendiri, Docker, Nginx, dan SSL gratis dari Let's Encrypt.

> 💡 Dikembangkan oleh [Gahar Inovasi Teknologi](https://github.com/mhanafi09051998)

---

## ✨ Fitur

- 🔧 Otomatis pasang semua dependensi (Node.js, Docker, Nginx, Certbot)
- ⚙️ Build Bolt.DIY langsung dari GitHub
- 🌐 Konfigurasi domain Anda agar diizinkan di Vite
- 🧶 Menggunakan `pnpm` untuk instalasi dependency yang cepat
- 🔁 Konfigurasi reverse proxy Nginx secara otomatis
- 🔐 Pasang SSL gratis dengan Let's Encrypt
- 🧼 Aman dijalankan ulang tanpa error

---

## 🚀 Cara Install

### ✅ Syarat VPS

- Sistem operasi: Ubuntu 20.04 / 22.04+
- Domain aktif yang sudah diarahkan ke IP VPS Anda (A record)
- Akses root atau user `sudo`

---

### 🛠️ Langkah Instalasi

```bash
git clone https://github.com/mhanafi09051998/bolt.diy-auto-installer-by-gahar-inovasi-teknologi-id.git
cd bolt.diy-auto-installer-by-gahar-inovasi-teknologi-id
chmod +x install.sh
./install.sh
```

📝 Anda akan diminta untuk memasukkan domain. Setelah itu, semua proses berjalan otomatis.

---

## 🌐 Setelah Instalasi

Bolt.DIY Anda akan tersedia di:

```
https://namadomainanda.com
```

Untuk melihat log atau kontrol container:

```bash
cd bolt.diy
sudo docker compose logs -f
```

Untuk memperbarui aplikasi:

```bash
cd bolt.diy
git pull
pnpm install
pnpm run build
sudo docker compose up -d --build
```

---

## ✅ Diuji Pada

- Ubuntu 22.04 LTS
- Node.js 20.x
- Docker v25+
- pnpm 9.x
- Nginx + Certbot

---

## ℹ️ Tentang Bolt.DIY

Bolt.DIY adalah antarmuka open-source yang memungkinkan Anda mengakses berbagai LLM seperti OpenAI, Ollama, LM Studio, dan lainnya — dengan performa tinggi, tampilan modern, dan 100% kontrol di tangan Anda.

---

## 🔐 Keamanan

- SSL otomatis via Let's Encrypt
- Reverse proxy menyembunyikan port internal
- Container Docker terisolasi dan auto restart

---

## 📎 Lisensi

Script auto installer ini open-source dan berlisensi MIT.

Aplikasi asli oleh StackBlitz:
> https://github.com/stackblitz-labs/bolt.diy

Dikembangkan dan dimodifikasi oleh:
> [Gahar Inovasi Teknologi](https://github.com/mhanafi09051998)

---

## ❤️ Dukungan

Silakan buka issue jika ada kendala, atau bintang ⭐ repo ini jika Anda merasa terbantu 🙌
