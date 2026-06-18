#!/usr/bin/env bash

set -uo pipefail

LOG_FILE="$HOME/monitor.log"
HIGH_CPU_COUNT=0

cleanup() {
    echo
    echo "Stopping monitor..."
    exit 0
}

trap cleanup SIGINT

while true
do
    echo "=============================="
    date

    # CPU usage
    CPU=$(top -bn1 | awk '/Cpu\(s\)/ {print 100 - $8}')

    # Memory usage
    MEM=$(free | awk '/Mem:/ {printf("%.2f"), $3/$2*100}')

    printf "CPU Usage : %.2f%%\n" "$CPU"
    printf "MEM Usage : %.2f%%\n" "$MEM"

    echo
    echo "Top 3 CPU processes"

    ps -eo pid,comm,%cpu --sort=-%cpu | head -n 4

    CPU_INT=$(printf "%.0f" "$CPU")

    if [ "$CPU_INT" -gt 80 ]; then
        HIGH_CPU_COUNT=$((HIGH_CPU_COUNT + 1))
    else
        HIGH_CPU_COUNT=0
    fi

    if [ "$HIGH_CPU_COUNT" -ge 3 ]; then
        echo "$(date): WARNING CPU usage ${CPU}% for 3 consecutive samples" >> "$LOG_FILE"
        HIGH_CPU_COUNT=0
    fi

    echo
    sleep 10
done
