#!/usr/bin/env bash
set -uo pipefail

# 1) Liệt kê 5 process tốn RAM nhất: cột PID + COMMAND + %MEM
echo "Top 5 processes by %MEM (PID COMMAND %MEM):"
ps -eo pid,comm,%mem --sort=-%mem | sed -n '2,6p'

# 2) Đếm số file .log trong /var/log (không đi sâu hơn 2 cấp)
echo
echo "Count of .log files in /var/log (maxdepth 2):"
find /var/log -maxdepth 2 -type f -name '*.log' 2>/dev/null | wc -l

# 3) Tìm 10 IP xuất hiện nhiều nhất trong /var/log/auth.log (nếu có)
echo
if [ -f /var/log/auth.log ]; then
  echo "Top 10 IPs in /var/log/auth.log:"
  # allow grep to return no matches without exiting script (pipefail + set -e)
  { grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' /var/log/auth.log 2>/dev/null || true; } \
    | sort \
    | uniq -c \
    | sort -rn \
    | head -n 10
else
  echo "/var/log/auth.log not found; skipping IP count."
fi

# 4) Lấy hostname + kernel version + uptime, ghi vào system-info.txt
host=$(hostname)
kernel=$(uname -r)
uptime_val=$(uptime -p 2>/dev/null || uptime)
# Determine the directory where this script resides and write output there
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
outfile="$script_dir/system-info.txt"
printf "host=%s\nkernel=%s\nuptime=%s\n" "$host" "$kernel" "$uptime_val" | tee "$outfile"
echo
echo "Wrote $outfile"