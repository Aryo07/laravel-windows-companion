# Laravel Windows Companion (Docker Services)

Project ini didesain khusus sebagai **"The Missing Piece"** untuk pengguna **Windows** (Laravel Herd, Laragon, atau XAMPP).

## 🤔 Kenapa Anda Membutuhkan Ini di Windows?

Jika Anda developer Laravel di Windows, Anda pasti merasakan keterbatasan ini dibandingkan pengguna Mac/Linux:

1. **Redis Tidak Support Windows**: Microsoft/Redis resmi menghentikan support native Redis di Windows bertahun-tahun lalu. Menginstallnya via MSI jadul sangat berisiko dan tidak update.
2. **Ribetnya Background Service**: Menjalankan Mailpit, Meilisearch, atau Redis secara manual (klik binary `.exe`) setiap kali restart laptop sangat melelahkan.
3. **Konflik Port**: Install MySQL 8.0 dan MariaDB 10.x sekaligus di Windows seringkali menyebabkan konflik service yang memusingkan.

**Solusinya:**
Gunakan Docker Tools ini sebagai pendamping **Laravel Herd** Anda!
Biarkan Herd mengurus PHP & Nginx (yang sudah sangat cepat), dan biarkan Docker ini mengurus sisanya (Database, Redis, Mailpit) secara rapi, terisolasi, dan **Auto-Start**.

---

## Layanan Tersedia & URL Akses

| Service                 | Port (Host)                                       | URL / Connection String                     | User / Pass              |
| :---------------------- | :------------------------------------------------ | :------------------------------------------ | :----------------------- |
| **MySQL 8.0**     | **3388**                                    | `127.0.0.1:3388`                          | `laravel` / `secret` |
| **MariaDB 10.11** | **3389**                                    | `127.0.0.1:3389`                          | `laravel` / `secret` |
| **Redis**         | **6379**                                    | `127.0.0.1:6379`                          | (No Password)            |
| **Mailpit**       | **8025** (Web)`<br>`**1025** (SMTP) | [http://localhost:8025](http://localhost:8025) | -                        |
| **Nexterm**       | **6989**                                    | [http://localhost:6989](http://localhost:6989) | (Setup di UI)            |

> **Catatan:** Password Root untuk MySQL/MariaDB adalah `root`

## 📥 Download Tools

Sebelum memulai, pastikan Anda sudah menginstall tools berikut:

| Tools                    | Deskripsi                                                         | Link Download                                                           |
| :----------------------- | :---------------------------------------------------------------- | :---------------------------------------------------------------------- |
| **Laravel Herd**   | PHP Environment tercepat untuk Windows (pengganti XAMPP/Laragon). | [Download Herd for Windows](https://herd.laravel.com/windows)              |
| **Docker Desktop** | Cara termudah menjalankan Docker di Windows.                      | [Download Docker Desktop](https://www.docker.com/products/docker-desktop/) |
| **Podman Desktop** | Alternatif Docker (Open Source) yang lebih ringan.                | [Download Podman Desktop](https://podman-desktop.io/downloads)             |

## Cara Install / Menjalankan

Berikut langkah-langkah lengkap dari awal:

1. **Clone Repository Ini**
   Buka terminal (PowerShell / Git Bash), lalu jalankan:

   ```bash
   git clone https://github.com/username/laravel-windows-companion.git
   cd laravel-windows-companion
   ```
2. **Setup Environment**
   Copy file template environment agar Anda bisa mengubah settingan port atau password:

   ```bash
   cp .env.docker .env
   ```

   *Silakan edit file `.env` jika ingin mengubah Port atau Password default.*
3. **Jalankan Docker**
   Pastikan aplikasi **Docker Desktop** sudah berjalan, lalu jalankan perintah:

   ```powershell
   ./setup.ps1
   ```

   *Script ini akan otomatis mendeteksi Docker/Podman, melakukan pull image dengan progress bar, build config, dan menjalankan container.*

   **Alternatif Manual:**
   Jika tidak ingin menggunakan script, jalankan:
   ```bash
   podman compose up -d
   ```

   *(Tunggu beberapa saat hingga proses download image selesai)*
4. **Selesai!**
   Semua service sekarang sudah berjalan di background.

   - Cek status: `docker compose ps`
   - Cek Mailpit: Buka browser ke `http://localhost:8025`

## Cara Pakai di Project Laravel (.env)

Copy-paste konfigurasi berikut ke file `.env` project Laravel Anda di Windows.

### 1. Database (Pilih salah satu)

**Opsi A: Menggunakan MySQL 8.0**

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3388           # Port untuk MySQL 8
DB_DATABASE=laravel    # Ganti dengan nama database Anda
DB_USERNAME=laravel
DB_PASSWORD=secret
```

**Opsi B: Menggunakan MariaDB 10.11**

```env
DB_CONNECTION=mariadb
DB_HOST=127.0.0.1
DB_PORT=3389           # Port untuk MariaDB 10.11
DB_DATABASE=laravel    # Ganti dengan nama database Anda
DB_USERNAME=laravel
DB_PASSWORD=secret
```

### 2. Redis (Cache, Queue, Session)

Redis di Windows via Docker ini jauh lebih stabil daripada install native `.msi`.

```env
CACHE_STORE=redis
QUEUE_CONNECTION=redis
SESSION_DRIVER=redis

# ...

REDIS_CLIENT=phpredis
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379
REDIS_PREFIX=myproject_   # Ubah sesuai nama project Anda!
```

### 3. Mailpit (SMTP Testing)

Email testing tanpa ribet jalanin binary manual.

```env
MAIL_MAILER=smtp
MAIL_SCHEME=null
MAIL_HOST=127.0.0.1
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="hello@example.com"
MAIL_FROM_NAME="${APP_NAME}"
```

## Konfigurasi Lanjutan (Optional)

- **Ubah Port & Password**: Edit file `.env` yang sudah Anda buat tadi.
- **Tuning Database**:
  - Konfigurasi ada di file `docker/mysql/my.cnf` dan `docker/mariadb/my.cnf`.
  - Berkat penggunaan `Dockerfile`, file ini sekarang **AMAN** dan pasti terbaca (permission fixed).
- **Restart**: Setiap mengubah config, jalankan `docker compose up -d --build`.

## 💡 Tips: Mengelola Banyak Database

Password dan Nama Database di file `.env` hanya digunakan untuk **Initial Setup** (saat container PERTAMA kali dibuat).

Untuk project kedua, ketiga, dst:

1. Buka DB Client (HeidiSQL, DBeaver, TablePlus).
2. Koneksi menggunakan `root` (password: `root`).
3. Buat database baru secara manual: `CREATE DATABASE project_baru;`
4. Di project Laravel baru, set `DB_DATABASE=project_baru` dst., bisa lihat **Cara Pakai di Project Laravel (.env)** di atas.

---

## 🚀 Perintah Docker / Podman Penting

Jika Anda menggunakan **Podman**, cukup ganti kata `docker` dengan `podman` (misal: `podman compose up -d`).

| Perintah                   | Fungsi                                                                                |
| :------------------------- | :------------------------------------------------------------------------------------ |
| `./setup.ps1`            | **Rekomendasi:** Install/Re-install otomatis dengan progress bar & fix timeout.       |
| `docker compose up -d`   | Menjalankan semua service di background (mode daemon).                                |
| `docker compose down`    | Mematikan dan**menghapus** container (Data database AMAN karena ada di Volume). |
| `docker compose start`   | Menyalakan kembali container yang berhenti (tanpa membuat ulang).                     |
| `docker compose stop`    | Memberhentikan container sementara.                                                   |
| `docker compose restart` | Restart container (berguna saat ubah config).                                         |
| `docker compose ps`      | Melihat status container yang sedang berjalan.                                        |
| `docker compose logs -f` | Melihat log output secara real-time (Ctrl+C untuk keluar).                            |

---

## 🛡️ Optimasi Disk & Kesehatan NVMe (PENTING)

Konfigurasi ini **SUDAH diterapkan otomatis** di repository ini demi menjaga kesehatan SSD/NVMe laptop Anda dan menghemat disk space.

### 1. Anti Disk Penuh (Log Rotation)

Seringkali Docker memakan disk puluhan GB hanya untuk file log sampah.
Di konfigurasi ini, kami membatasi log secara ketat di `docker-compose.yml`:

- **Max Size:** 10MB per file.
- **Max File:** 3 file rotasi.
- **Efek:** Total log per service maksimal hanya **30MB**. Log lama otomatis dihapus. Disk Anda **AMAN** dari kepenuhan.

### 2. Anti NVMe Rusak (Database Buffer)

Secara default, MySQL/MariaDB melakukan "Physical Write" ke SSD setiap kali ada transaksi (insert/update). Ini bisa membunuh umur (TBW) NVMe Anda dengan cepat saat development.

Kami mengubah setting di `my.cnf` menjadi:

```ini
innodb_flush_log_at_trx_commit = 2
```

- **Cara Kerja:** Transaksi disimpan di RAM dulu, baru ditulis ke fisik NVMe setiap **1 detik sekali**.
- **Efek:** Mengurangi aktivitas *write* fisik hingga **100x lipat**. NVMe jauh lebih awet & database lebih responsif.
- **Trade-off:** Jika PC mati lampu mendadak, data transaksi **1 detik terakhir** mungkin hilang. (Sangat aman untuk Local Development).

---

## 🔄 Cara Update Aplikasi / Image

Aplikasi seperti MySQL, Redis, dan Mailpit terus mendapatkan update (perbaikan bug / fitur baru).
Untuk mengupdate container Anda ke versi terbaru (sesuai tag yang ada di `docker-compose.yml`):

1. **Download Image Base Terbaru & Build Ulang:**

   ```bash
   docker compose pull
   docker compose build --no-cache

   atau (gunakan dengan hati-hati)
   podman compose up -d --build --force-recreate
   ```
   *(Penting: Karena sekarang kita pakai config custom, kita harus melakukan `build` ulang setiap ada update)*.
2. **Terapkan Update:**
   Re-create container:

   ```bash
   docker compose up -d
   ```
   *(Data database tetap **AMAN**)*.
3. **Hapus Image Lama (Bersih-bersih):**
   Setelah update, image lama biasanya jadi "dangling" (tidak terpakai). Hapus untuk hemat disk:

   ```bash
   docker image prune -f
   ```
