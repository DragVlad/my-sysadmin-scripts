#!/bin/bash

disk_1="/dev/sdb" 
disk_2="/dev/sdc"
raid_name="/dev/md0"
vg_name="vg_storage"
lv_name="lv_logs"

install_docker() {
    if command -v docker &>/dev/null; then
        echo -e "\e[32mPass install, Docker installed\033[0m"
    else
        echo -e "\e[32mDocker non installed, start install process\033[0m"
        sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc docker-buildx podman-docker containerd runc | cut -f1)
        sudo apt update
        sudo apt install -y ca-certificates curl
        sudo install -m 0755 -d /etc/apt/keyrings
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc
        sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null << EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
        sudo apt update
        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        sudo systemctl enable --now docker
        sudo systemctl status docker --no-pager || truedock
        echo -e "\e[32mSuccess install Docker!\033[0m"
        docker -v
    fi
}

make_raid() {
    if grep -q '^md' /proc/mdstat 2>/dev/null; then
        echo -e "\e[32mRaid massive is ready, pass\033[0m"
    else
        echo -e "\e[32mStart make Raid\033[0m"
        yes | sudo mdadm --create $raid_name --level=1 --raid-devices=2 $disk_1 $disk_2
        echo -e "\e[32mWait for make Raid\033[0m"
        while grep -q 'resync' /proc/mdstat; do
            sleep 1
        done
        cat /proc/mdstat
        echo -e "\e[32mRaid $raid_name Ready\033[0m"
        lsblk
    fi
}

make_pvs() {
    if sudo pvs 2>/dev/null | grep -q '/dev/md0'; then
        echo -e "\e[32mPVS is ready, pass\033[0m"
    else
        sudo pvcreate $raid_name
        sudo pvs
        echo -e "\e[32mPVS is created\033[0m"
    fi
}

make_vg() {
    if sudo vgs 2>/dev/null | grep -q "$vg_name"; then
        echo -e "\e[32mVG is ready, pass\033[0m"
    else
        sudo vgcreate $vg_name $raid_name
        sudo vgs
        echo -e "\e[32mVolume group $vg_name is created\033[0m"
    fi
}

make_lv() {
    if sudo lvs 2>/dev/null | grep -q "$lv_name"; then
        echo -e "\e[32mLogical volume $lv_name is ready, pass\033[0m"
    else
        yes | sudo lvcreate -n $lv_name -l 100%VG $vg_name
        sudo lvs
        echo -e "\e[32mLogical volume $lv_name is created\033[0m"
    fi
}

make_filesystem() {
    if lsblk -f /dev/$vg_name/$lv_name | grep -q "ext4"; then
        echo -e "\e[32mFileSystem ready, pass\033[0m"
    else
        echo -e "\e[32mFileSystem not ready\033[0m"
        sudo mkfs.ext4 /dev/$vg_name/$lv_name
        sudo blkid
        echo -e "\e[32mFileSystem ready\033[0m"
    fi
}

lv_mount() {
    if df -h | grep "/dev/mapper/$vg_name-$lv_name"; then
        echo -e "\e[32m/dev/$vg_name/$lv_name mounted, pass\033[0m"
    else
        echo -e "\e[32m/dev/$vg_name/$lv_name not mounted\033[0m"
        sudo mount /dev/$vg_name/$lv_name /var/log
        echo -e "\e[32m/dev/$vg_name/$lv_name mounted\033[0m"
        df -h
        uuid=$(sudo blkid -s UUID -o value /dev/$vg_name/$lv_name)
        sudo tee -a /etc/fstab >/dev/null <<EOF
UUID=${uuid}  /var/storage/smb  ext4  defaults  0 2
EOF
        echo -e "\e[32m$uuid added to /etc/fstab\033[0m"
    fi
}

install_docker
make_raid
make_pvs
make_vg
make_lv
make_filesystem
lv_mount
