#!/bin/bash

N=5
LOG_FILE="monitor.log"

while true; do
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    echo "--- $TIMESTAMP ---" >> "$LOG_FILE"
    free -h >> "$LOG_FILE"
    df -h >> "$LOG_FILE"
    uptime >> "$LOG_FILE"
    sleep $N
done
