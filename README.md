<div align="center">

<img src="https://img.shields.io/badge/NVIDIA-Jetson%20Nano-76B900?style=for-the-badge&logo=nvidia&logoColor=white"/>
<img src="https://img.shields.io/badge/Shell-Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white"/>
<img src="https://img.shields.io/badge/Platform-Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black"/>
<img src="https://img.shields.io/badge/License-MIT-blue?style=for-the-badge"/>

# 🗂️ Jetson Nano SD Card Backup Tool

**[🇹🇷 Türkçe](#-türkçe) · [🇬🇧 English](#-english)**

</div>

---

## 🇹🇷 Türkçe

### 📖 Hakkında

**Jetson Nano SD Kart Yedekleme Scripti**, NVIDIA Jetson Nano'nuzun SD kartını tek komutla yedekleyen ve farklı bir karta geri yükleyen interaktif bir Bash scriptidir. Sıkıştırılmış imaj (`.img.gz`) formatını kullanarak disk alanından tasarruf sağlar.

### ✨ Özellikler

- 🔍 **Otomatik SD Kart Tespiti** — Çıkarılabilir diskleri otomatik olarak algılar
- 📦 **Sıkıştırılmış Yedekleme** — `dd + gzip` pipeline ile alan tasarrufu
- 🔄 **Tek Adımda Geri Yükleme** — Yedek → hedef kart aktarımı aynı script içinde
- 🔒 **Güvenlik Onayı** — Kritik işlemler öncesi kullanıcı onayı ister
- 🖥️ **Renkli Terminal Çıktısı** — Bilgi, başarı, uyarı ve hata mesajları renk kodlu
- 💾 **Otomatik Unmount** — İşlem öncesi tüm partitionlar güvenle ayrılır
- ⏏️ **Otomatik Eject** — Yedekleme sonrası SD kart güvenle çıkarılır

### ⚙️ Gereksinimler

| Gereksinim | Açıklama |
|---|---|
| **OS** | Linux (Ubuntu 18.04+ önerilir) |
| **Araçlar** | `dd`, `gzip`, `lsblk`, `eject`, `sudo` |
| **İzin** | `sudo` yetkisi gereklidir |
| **Donanım** | USB SD kart okuyucu |

### 🚀 Kullanım

#### 1. Scripti İndirin

```bash
git clone https://github.com/ozaysahin/jetson-autobackup.git
cd jetson-nano-sd-backup
```

#### 2. Çalıştırma İzni Verin

```bash
chmod +x jetson_backup.sh
```

#### 3. Scripti Çalıştırın

```bash
./jetson_backup.sh
```

#### 4. Adım Adım Akış

```
1. Yedeklenecek SD kartı takın → Enter'a basın
2. Script kartı otomatik tespit eder
3. Onay verin → Yedek alınmaya başlar
4. Yedekleme tamamlanınca kart otomatik çıkarılır
5. Hedef SD kartı takın → Enter'a basın
6. Onay verin → Geri yükleme başlar
7. Tamamlandı! Kartı Jetson Nano'ya takıp test edin.
```

### 📁 Yedek Dosyası

Yedek dosyası varsayılan olarak şuraya kaydedilir:

```
~/Desktop/backup.img.gz
```

Farklı bir konum için scriptin başındaki değişkeni düzenleyin:

```bash
BACKUP_PATH="$HOME/Desktop/backup.img.gz"  # ← burası
```

### ⚠️ Önemli Uyarılar

> [!CAUTION]
> Geri yükleme işlemi hedef SD karttaki **tüm verileri kalıcı olarak siler**. Doğru diski seçtiğinizden emin olun.

> [!WARNING]
> Script `sudo` yetkisi gerektirir. Kaynak disk olarak sistem diskini (`/dev/sda`) seçmeyin.

> [!TIP]
> Büyük SD kartlarda (64GB+) yedekleme uzun sürebilir. Terminal oturumunu kapatmayın.

### 🛠️ Sorun Giderme

| Sorun | Çözüm |
|---|---|
| SD kart tespit edilemiyor | Farklı bir USB portu deneyin, `lsblk` ile kontrol edin |
| Unmount başarısız | Kartı kullanan uygulamaları kapatın |
| İzin hatası | `sudo` erişiminizi kontrol edin |
| Eject başarısız | Manuel olarak çıkarabilirsiniz, veriler güvende |

---

## 🇬🇧 English

### 📖 About

**Jetson Nano SD Card Backup Script** is an interactive Bash utility that backs up your NVIDIA Jetson Nano's SD card with a single command and restores it to a new card. It uses compressed image (`.img.gz`) format to save disk space.

### ✨ Features

- 🔍 **Auto SD Card Detection** — Automatically detects removable block devices
- 📦 **Compressed Backup** — Saves space using a `dd + gzip` pipeline
- 🔄 **One-Script Restore** — Backup and restore in the same workflow
- 🔒 **Safety Confirmation** — Prompts for user confirmation before destructive operations
- 🖥️ **Color-coded Terminal Output** — Info, success, warning and error messages
- 💾 **Auto Unmount** — Safely unmounts all partitions before operations
- ⏏️ **Auto Eject** — Safely ejects the SD card after backup completes

### ⚙️ Requirements

| Requirement | Description |
|---|---|
| **OS** | Linux (Ubuntu 18.04+ recommended) |
| **Tools** | `dd`, `gzip`, `lsblk`, `eject`, `sudo` |
| **Permission** | `sudo` access required |
| **Hardware** | USB SD card reader |

### 🚀 Usage

#### 1. Clone the Repository

```bash
git clone https://github.com/ozaysahin/jetson-autobackup.git
cd jetson-nano-sd-backup
```

#### 2. Make It Executable

```bash
chmod +x jetson_backup_en.sh
```

#### 3. Run the Script

```bash
./jetson_backup_en.sh
```

#### 4. Step-by-Step Flow

```
1. Insert the SD card to be backed up → Press Enter
2. Script auto-detects the card
3. Confirm → Backup begins
4. Card is auto-ejected when backup completes
5. Insert the target SD card → Press Enter
6. Confirm → Restore begins
7. Done! Insert card into Jetson Nano and test.
```

### 📁 Backup File Location

By default, the backup is saved to:

```
~/Desktop/backup.img.gz
```

To change the location, edit the variable at the top of the script:

```bash
BACKUP_PATH="$HOME/Desktop/backup.img.gz"  # ← change this
```

### ⚠️ Important Warnings

> [!CAUTION]
> The restore operation **permanently erases all data** on the target SD card. Make sure you select the correct disk.

> [!WARNING]
> The script requires `sudo` privileges. Never select your system disk (`/dev/sda`) as the source.

> [!TIP]
> Backup of large SD cards (64GB+) may take a long time. Do not close the terminal session.

### 🛠️ Troubleshooting

| Issue | Solution |
|---|---|
| SD card not detected | Try a different USB port, verify with `lsblk` |
| Unmount fails | Close any applications using the card |
| Permission error | Check your `sudo` access |
| Eject fails | You can remove it manually — data is safe |

---

## 📜 License

This project is licensed under the [MIT License](LICENSE).

---

<div align="center">

Made with ❤️ for the Jetson Nano community

</div>
