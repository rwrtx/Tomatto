#!/bin/bash

# Ambil tanggal dari server
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=$(date +"%Y-%m-%d" -d "$dateFromServer")

# Warna dan tema
colornow=$(cat /etc/rmbl/theme/color.conf)
export NC="\e[0m"
export YELLOW='\033[0;33m'
export RED="\033[0;31m"
export COLOR1=$(cat /etc/rmbl/theme/$colornow | grep -w "TEXT" | cut -d: -f2 | sed 's/ //g')
export COLBG1=$(cat /etc/rmbl/theme/$colornow | grep -w "BG" | cut -d: -f2 | sed 's/ //g')
WH='\033[1;37m'

# Ambil IP server
ipsaya=$(wget -qO- ipinfo.io/ip)
data_server=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
date_list=$(date +"%Y-%m-%d" -d "$data_server")
data_ip="https://raw.githubusercontent.com/rwrtx/vvipsc/main/izin"

# Fungsi untuk pengecekan izin script
checking_sc() {
    useexp=$(curl -sS $data_ip | grep $ipsaya | awk '{print $3}')
    if [[ $date_list < $useexp ]]; then
        echo -ne
    else
        systemctl stop nginx
        echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
        echo -e "$COLOR1│${NC}${COLBG1}          ${WH}• AUTOSCRIPT PREMIUM •                 ${NC}$COLOR1│ $NC"
        echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
        echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
        echo -e "$COLOR1│            ${RED}PERMISSION DENIED !${NC}                  $COLOR1│"
        echo -e "$COLOR1│   ${yl}Your VPS${NC} $ipsaya \033[0;36mHas been Banned${NC}      $COLOR1│"
        echo -e "$COLOR1│     ${yl}Buy access permissions for scripts${NC}          $COLOR1│"
        echo -e "$COLOR1│             \033[0;32mContact Your Admin ${NC}                 $COLOR1│"
        echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
        exit
    fi
}
checking_sc

clear
echo ""
echo "This Feature Can Only Be Used According To VPS Data With This Autoscript"
echo "Please Insert VPS Data Backup Link To Restore The Data"
echo ""
read -rp "Link File: " -e url
cd
mkdir -p /root/backup
wget -O backup.zip "$url"
unzip backup.zip &> /dev/null
rm -f backup.zip
sleep 1
echo "Start Restore"
cd /root/backup
echo -e "[ ${YELLOW}INFO${NC} ] Start Restore . . . "

# Pindahkan file konfigurasi dasar
cp -r passwd /etc/ &> /dev/null
cp -r group /etc/ &> /dev/null
cp -r shadow /etc/ &> /dev/null
cp -r ssh /etc/xray/ssh &> /dev/null
cp -r idchat /usr/bin/idchat &> /dev/null
cp -r token /usr/bin/token &> /dev/null
cp -r id /etc/per/id &> /dev/null
cp -r token2 /etc/per/token &> /dev/null
cp -r loginid /etc/perlogin/id &> /dev/null
cp -r logintoken /etc/perlogin/token &> /dev/null
cp -r public_html /home/vps/ &> /dev/null
cp -r gshadow /etc/ &> /dev/null
cp -r sshx /etc/xray/ &> /dev/null
cp -r vmess /etc/ &> /dev/null
cp -r vless /etc/ &> /dev/null
cp -r trojan /etc/ &> /dev/null
cp -r issue /etc/issue.net &> /dev/null

# Proses khusus untuk config.json Xray
current_config="/etc/xray/config.json"
backup_config="/root/backup/xray/config.json"

# Cek apakah config.json berbeda
if ! cmp -s "$current_config" "$backup_config"; then
    echo "Config.json berbeda. Menjaga konfigurasi yang ada, hanya memperbarui data user."
    
    # Ekstrak data user dari backup config.json
    jq '.inbounds[0].settings.clients' "$backup_config" > /tmp/users_from_backup.json
    
    # Tambahkan data user dari backup ke config.json yang ada di server
    jq '.inbounds[0].settings.clients += input' "$current_config" /tmp/users_from_backup.json > /tmp/new_config.json
    
    # Gantikan config.json dengan versi yang diperbarui
    mv /tmp/new_config.json "$current_config"
    
    echo "Data user berhasil ditambahkan ke config.json yang ada."
else
    echo "Config.json sama. Tidak ada perubahan."
fi

# Restart layanan
echo -e "[ ${YELLOW}INFO${NC} ] VPS Data Restore Complete!"
echo ""
echo -e "[ ${YELLOW}INFO${NC} ] Restart All Services"
systemctl restart xray
systemctl restart nginx
cd
rm -rf *
sleep 0.5
read -n 1 -s -r -p "Press any key to back on menu"
menu
