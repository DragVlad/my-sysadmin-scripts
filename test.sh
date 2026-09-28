#!/bin/bash
# тесты для самопроверки

disk_1="/dev/sdb" 
disk_2="/dev/sdc"
raid_name="/dev/md0"
vg_name="vg_storage"
lv_name="lv_logs"

make_test() {
    echo -e "\e[32mRaid status\033[0m"
    cat /proc/mdstat
    sudo blkid | grep linux_raid_member

    echo -e "\e[32mPVS, VG, LVS status\033[0m"
    sudo pvs
    sudo vgs
    sudo lvs
    sudo blkid | grep $lv_name

    echo -e "\e[32mDevices status\033[0m"
    lsblk

    echo -e "\e[32mMount status\033[0m"
    cat /etc/fstab
    df -h

    echo -e "\e[32mDocker status\033[0m"
    docker compose ps

    echo -e "\e[32mSystemd my_app status\033[0m"
    systemctl status my-app.service

    echo -e "\e[32mAvailability my_app status\033[0m"
    curl -kI https://127.0.0.1/
    curl -kI http://127.0.0.1:8080
    curl -k https://127.0.0.1/monitor.log | tail -n 10
    curl -vk https://127.0.0.1
    curl -kI http://127.0.0.1/

    echo -e "\e[32mNginx status\033[0m"
    sudo nginx -t
    systemctl status nginx

    echo -e "\e[32mjournalctl and access.log\033[0m"
    sudo journalctl -u my-app | tail -n 10
    sudo cat /var/log/nginx/access.log | tail -n 10
}

make_test
