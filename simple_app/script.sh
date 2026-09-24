#!/bin/sh

N=5
LOG_FILE="/var/www/monitor.log"

while true; do
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    echo "--- $TIMESTAMP ---" >> "$LOG_FILE"
    echo "--- Состояние оперативной памяти ---" >> "$LOG_FILE"
    free -h >> "$LOG_FILE"
    echo "--- Состояние дискового пространства ---" >> "$LOG_FILE"
    df -h >> "$LOG_FILE"
    echo "--- Средняя нагрузка на CPU ---" >> "$LOG_FILE"
    uptime >> "$LOG_FILE"
    sleep $N
done
