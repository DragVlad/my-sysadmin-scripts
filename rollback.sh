#!/bin/bash

disk_1="/dev/sdb" 
disk_2="/dev/sdc"
raid_name="/dev/md0"
vg_name="vg_storage"
lv_name="lv_logs"

sudo systemctl stop my-app
sudo systemctl disable my-app
sudo rm /etc/systemd/system/my-app.service
sudo systemctl daemon-reload
sudo systemctl reset-failed

sudo systemctl stop nginx
sudo rm -f /etc/nginx/sites-enabled/my-app
sudo rm -f /etc/nginx/sites-available/my-app
sudo apt purge nginx nginx-common nginx-core -y
sudo apt autoremove --purge -y
sudo systemctl daemon-reload

sudo rm -f /etc/ssl/private/my-app.key /etc/ssl/certs/my-app.crt

docker compose down
sudo systemctl stop docker
sudo docker rm -f $(sudo docker ps -aq) 2>/dev/null
sudo docker rmi -f $(sudo docker images -aq) 2>/dev/null
sudo docker volume rm $(sudo docker volume ls -q) 2>/dev/null
sudo docker network prune -f
sudo docker system prune -a --volumes -f
sudo systemctl stop docker docker.socket containerd
sudo systemctl disable docker docker.socket containerd
sudo apt purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras -y
sudo apt autoremove --purge -y
sudo apt purge docker-compose -y

sudo sed -i '\|[[:space:]]/var/log[[:space:]]|d' /etc/fstab
sudo umount /dev/mapper/vg_storage-lv_logs

sudo lvremove -f /dev/$vg_name/$lv_name
sudo lvs

sudo vgremove -f $vg_name
sudo vgs

sudo pvremove -f $raid_name
sudo pvs

sudo mdadm --stop $raid_name

sudo mdadm --zero-superblock $disk_1
sudo mdadm --zero-superblock $disk_2

sudo dd if=/dev/zero of=$disk_1 bs=1M count=100 status=progress
sudo dd if=/dev/zero of=$disk_2 bs=1M count=100 status=progress

lsblk
cat /proc/mdstat
