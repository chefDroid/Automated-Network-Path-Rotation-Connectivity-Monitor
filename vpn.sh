#!/bin/bash

# =========================
# COLOR DEFINITIONS
# =========================
GREEN="\033[1;32m"
RED="\033[1;31m"
PURPLE="\033[1;35m"
RESET="\033[0m"

VPN_DIR="/home/kasgoat/vpn-configs"
LOG="/home/kasgoat/vpn-rotate.log"
AUTH_FILE="$VPN_DIR/auth.text"

# =========================
# FUNCTION – CLEAR SCREEN
# =========================
clear_screen() {
printf "\033[2J\033[H"
}

# =========================
# ASCII PUNISHER SKULL
# =========================
SKULL="
███████████████████████
████▀─────────────▀████
███│ █████████ │███
███│ ██▀──▀██ │███
███│ █████████ │███
███│ ██▀──▀██ │███
███│ █████████ │███
████▄─────────────▄████
███████████████████████
"

BOTTOM="
══════════════════════════════════════════════════════
Automated Network Path Rotation & Connectivity Monitor
══════════════════════════════════════════════════════
"

# =========================
# FUNCTION – FLASH SKULL
# =========================
flash_skull() {
clear_screen
echo -e "${GREEN}${SKULL}${RESET}"
echo -e "${PURPLE} access granted!${RESET}"
echo -e "${PURPLE}${BOTTOM}${RESET}"
sleep 0.4

clear_screen
echo -e "${RED}${SKULL}${RESET}"
echo -e "${PURPLE} Created By ISpyasPY.INC${RESET}"
echo -e "${PURPLE}${BOTTOM}${RESET}"
sleep 0.4
}

# =========================
# FUNCTION – ROTATE VPNS
# =========================
reset_network() {
echo "[*] Resetting network..." | tee -a "$LOG"
pkill openvpn
sleep 2

sudo systemctl restart NetworkManager
sudo systemctl restart systemd-resolved

sudo rm -f /etc/resolv.conf
sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
}

rotate_vpn() {
CONFIG=$(ls "$VPN_DIR"/*.ovpn 2>/dev/null | shuf -n 1)

if [ -z "$CONFIG" ]; then
echo "[!] No VPN configs found" | tee -a "$LOG"
return
fi

echo -e "${Purple}[*] Switching to $CONFIG" | tee -a "$LOG"

pkill openvpn
sleep 3

sudo openvpn --config "$CONFIG" --daemon
sleep 15

if ip a | grep -q tun0; then
echo "[+] VPN connected (tun0 up)" | tee -a "$LOG"
else
echo "[!] VPN failed — restoring normal internet" | tee -a "$LOG"
reset_network
fi
}

while true; do
flash_skull
rotate_vpn
sleep 300 # 5 minutes (YOU WERE MISSING THIS)
done
