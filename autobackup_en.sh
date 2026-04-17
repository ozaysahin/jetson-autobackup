#!/bin/bash

BACKUP_PATH="$HOME/Desktop/backup.img.gz"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

print_info()    { echo -e "${CYAN}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# Auto SD card detection
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
    print_info "Unmounting all partitions on $DISK..."
    for part in ${DISK}*; do
        if mountpoint -q "$part" 2>/dev/null || grep -q "^$part " /proc/mounts 2>/dev/null; then
            sudo umount "$part" 2>/dev/null && print_info "$part unmounted."
        fi
    done
    print_success "Unmount completed."
}

# ── Header ──────────────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║    Jetson Nano SD Card Backup & Restore      ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
echo ""

# ── Backup ──────────────────────────────────────────────────────────────────
print_warning "Insert the SD card to be backed up, then press Enter."
read -r

print_info "Detecting SD card..."
sleep 2

SOURCE_DISK=$(detect_sd_card)

if [ -z "$SOURCE_DISK" ]; then
    print_error "No SD card found. Make sure it is properly inserted."
    exit 1
fi

print_success "SD card found: $SOURCE_DISK"
DISK_SIZE=$(lsblk -d -o SIZE "$SOURCE_DISK" | tail -1)
print_info "Disk size: $DISK_SIZE"

echo ""
print_warning "A backup of $SOURCE_DISK will be created. Do you want to continue? (y/n)"
read -r CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    print_info "Operation cancelled."
    exit 0
fi

unmount_disk "$SOURCE_DISK"

mkdir -p "$(dirname "$BACKUP_PATH")"

echo ""
print_info "Creating backup: $SOURCE_DISK → $BACKUP_PATH"
print_warning "This may take a long time. Do not close the terminal."
echo ""

sudo dd if="$SOURCE_DISK" conv=sync,noerror bs=64K 2>/tmp/dd_stderr | gzip -c > "$BACKUP_PATH"
DD_EXIT=${PIPESTATUS[0]}

if [ $DD_EXIT -ne 0 ]; then
    print_error "An error occurred during backup."
    cat /tmp/dd_stderr
    exit 1
fi

echo ""
print_success "╔══════════════════════════════════════════════╗"
print_success "║           BACKUP COMPLETED SUCCESSFULLY!     ║"
print_success "╚══════════════════════════════════════════════╝"
print_info "Backup file: $BACKUP_PATH"
print_info "File size:   $(du -h "$BACKUP_PATH" | cut -f1)"

# Eject source card
echo ""
print_info "Ejecting SD card..."
sudo eject "$SOURCE_DISK" 2>/dev/null && print_success "You can safely remove the SD card." || print_warning "Eject failed. You can remove it manually."

# ── Restore ─────────────────────────────────────────────────────────────────
echo ""
echo -e "${YELLOW}════════════════════════════════════════════════${NC}"
print_warning "Insert the target SD card (restore destination), then press Enter."
read -r

print_info "Detecting SD card..."
sleep 2

TARGET_DISK=$(detect_sd_card)

if [ -z "$TARGET_DISK" ]; then
    print_error "No SD card found. Make sure it is properly inserted."
    exit 1
fi

print_success "Target SD card found: $TARGET_DISK"
TARGET_SIZE=$(lsblk -d -o SIZE "$TARGET_DISK" | tail -1)
print_info "Target disk size: $TARGET_SIZE"

echo ""
print_warning "ALL DATA on $TARGET_DISK will be permanently erased."
print_warning "Do you want to continue? (y/n)"
read -r CONFIRM2
if [[ "$CONFIRM2" != "y" && "$CONFIRM2" != "Y" ]]; then
    print_info "Operation cancelled."
    exit 0
fi

unmount_disk "$TARGET_DISK"

echo ""
print_info "Restoring backup: $BACKUP_PATH → $TARGET_DISK"
print_warning "This may take a long time. Do not close the terminal."
echo ""

sudo su -c "gunzip -c '$BACKUP_PATH' | dd of='$TARGET_DISK' bs=64K"
RESTORE_EXIT=${PIPESTATUS[1]}

if [ $RESTORE_EXIT -ne 0 ]; then
    print_error "An error occurred during restore."
    exit 1
fi

echo ""
print_success "╔══════════════════════════════════════════════╗"
print_success "║         RESTORE COMPLETED SUCCESSFULLY!      ║"
print_success "║   Insert the SD card into Jetson Nano        ║"
print_success "║   and power it on to verify.                 ║"
print_success "╚══════════════════════════════════════════════╝"
echo ""
