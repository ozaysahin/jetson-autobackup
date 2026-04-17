BACKUP_PATH="$HOME/Desktop/backup.img.gz"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

print_info()    { echo -e "${CYAN}[BİLGİ]${NC} $1"; }
print_success() { echo -e "${GREEN}[BAŞARI]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[UYARI]${NC} $1"; }
print_error()   { echo -e "${RED}[HATA]${NC} $1"; }

# sd card oto detection 
detect_sd_card() {
    local DETECTED=""
    for disk in /dev/sd[b-z]; do
        [ -b "$disk" ] || continue
        local dev=$(basename "$disk")
        local removable=$(cat /sys/block/$dev/removable 2>/dev/null)
        if [ "$removable" = "1" ]; then
            DETECTED="$disk"
            break
        fi
    done
    echo "$DETECTED"
}

unmount_disk() {
    local DISK=$1
    print_info "$DISK üzerindeki tüm partlar unmount edildi"
    for part in ${DISK}*; do
        if mountpoint -q "$part" 2>/dev/null || grep -q "^$part " /proc/mounts 2>/dev/null; then
            sudo umount "$part" 2>/dev/null && print_info "$part unmount edildi."
        fi
    done
    print_success "unmount işlemi tamamlandı"
}

# backupu alma
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     Jetson Nano SD Kart Yedekleme Scripti    ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
echo ""

print_warning "yedeklenecek kartı takıp entera basın"
read -r

print_info "sd kart okunuyor"
sleep 2 

SOURCE_DISK=$(detect_sd_card)

if [ -z "$SOURCE_DISK" ]; then
    print_error "sd kart bulunamadı düzgün takıldığından emin olun"
    exit 1
fi

print_success "bulunan sd kart: $SOURCE_DISK"
DISK_SIZE=$(lsblk -d -o SIZE "$SOURCE_DISK" | tail -1)
print_info "disk boyutu: $DISK_SIZE"

echo ""
print_warning "$SOURCE_DISK diskinin yedeği alınacak devam etmek istiyor musunuz? (e/h)"
read -r CONFIRM
if [[ "$CONFIRM" != "e" && "$CONFIRM" != "E" ]]; then
    print_info "işlem iptal edildi"
    exit 0
fi

unmount_disk "$SOURCE_DISK"

mkdir -p "$(dirname "$BACKUP_PATH")"

# backup alma
echo ""
print_info "yedek alınıyor: $SOURCE_DISK → $BACKUP_PATH"
print_warning "bu işlem uzun sürebilir terminali kapatmayın"
echo ""

sudo dd if="$SOURCE_DISK" conv=sync,noerror bs=64K 2>/tmp/dd_stderr | gzip -c > "$BACKUP_PATH"
DD_EXIT=${PIPESTATUS[0]}

if [ $DD_EXIT -ne 0 ]; then
    print_error "yedekleme sırasında hata oluştu"
    cat /tmp/dd_stderr
    exit 1
fi

echo ""
print_success "╔══════════════════════════════════════════════╗"
print_success "║         YEDEKLEME BAŞARIYLA TAMAMLANDI!      ║"
print_success "╚══════════════════════════════════════════════╝"
print_info "yedek dosyası: $BACKUP_PATH"
print_info "dosya boyutu: $(du -h "$BACKUP_PATH" | cut -f1)"

# eject
echo ""
print_info "sd kart çıkartılıyor."
sudo eject "$SOURCE_DISK" 2>/dev/null && print_success "sd kartı çıkartabilirsiniz" || print_warning "eject başarısız."

# geri yükleme kısmı
echo ""
echo -e "${YELLOW}════════════════════════════════════════════════${NC}"
print_warning "backupun aktarılacağı sd kartı takın ve entera basın"
read -r

print_info "sd kart okunuyor"
sleep 2

TARGET_DISK=$(detect_sd_card)

if [ -z "$TARGET_DISK" ]; then
    print_error "sd kart okunamadı lütfen doğru taktığınıza emin olun"
    exit 1
fi

print_success "sd kart bulundu: $TARGET_DISK"
TARGET_SIZE=$(lsblk -d -o SIZE "$TARGET_DISK" | tail -1)
print_info "hedef disk boyutu: $TARGET_SIZE"

echo ""
print_warning "$TARGET_DISK diskindeki tüm veriler silinecek"
print_warning "devam etmek istiyor musunuz? (e/h)"
read -r CONFIRM2
if [[ "$CONFIRM2" != "e" && "$CONFIRM2" != "E" ]]; then
    print_info "işlem iptal edildi"
    exit 0
fi

unmount_disk "$TARGET_DISK"

echo ""
print_info "yedek geri yükleniyor: $BACKUP_PATH → $TARGET_DISK"
print_warning "bu işlem uzun sürebilir terminali kapatmayın"
echo ""

sudo su -c "gunzip -c '$BACKUP_PATH' | dd of='$TARGET_DISK' bs=64K"
RESTORE_EXIT=${PIPESTATUS[1]}

if [ $RESTORE_EXIT -ne 0 ]; then
    print_error "geri yükleme sırasında hata oluştu"
    exit 1
fi

echo ""
print_success "╔══════════════════════════════════════════════╗"
print_success "║       GERİ YÜKLEME BAŞARIYLA TAMAMLANDI!     ║"
print_success "║   SD kartı Jetson Nano'ya takıp test edin.   ║"
print_success "╚══════════════════════════════════════════════╝"
echo ""
