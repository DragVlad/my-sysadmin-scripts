#!/bin/bash

disk_1="/dev/sdb" 
disk_2="/dev/sdc"
raid_sleep=120

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
    if command cat /proc/mdstat &>/dev/null; then
        echo -e "\e[32mRaid massive is ready, pass\033[0m"
        docker -v
    fi
}

make_raid() {
    if grep -q '^md' /proc/mdstat 2>/dev/null; then
        echo -e "\e[32mRaid massive is ready, pass\033[0m"
    else
        echo -e "\e[32mStart make Raid\033[0m"
        yes | sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 $disk_1 $disk_2
        echo -e "\e[32mWait for make Raid\033[0m"
        while grep -q 'resync' /proc/mdstat; do
            sleep 1
        done
        cat /proc/mdstat
        echo -e "\e[32mRaid /dev/md0 Ready\033[0m"
        lsblk
    fi
}

install_docker
make_raid
