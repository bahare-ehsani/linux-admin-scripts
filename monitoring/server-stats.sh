#!/usr/bin/env bash

# server-stats.sh
# Displays basic Linux server performance statistics.

set -o pipefail

print_section() {
    printf '\n========== %s ==========\n' "$1"
}

# Check required commands
for cmd in awk ps df free uptime hostname; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        printf 'Error: Required command "%s" is not installed.\n' "$cmd" >&2
        exit 1
    fi
done

# System information
print_section "SYSTEM INFORMATION"

if [[ -r /etc/os-release ]]; then
    . /etc/os-release
    printf 'OS: %s\n' "${PRETTY_NAME:-Unknown}"
fi

printf 'Hostname: %s\n' "$(hostname)"
printf 'Uptime: '
uptime -p 2>/dev/null || uptime

printf 'Load Average: '
awk '{print $1, $2, $3}' /proc/loadavg

# CPU usage
print_section "CPU USAGE"

read_cpu_stats() {
    awk '/^cpu / {
        idle = $5 + $6
        total = 0
        for (i = 2; i <= NF; i++) {
            total += $i
        }
        print total, idle
        exit
    }' /proc/stat
}

read -r total1 idle1 < <(read_cpu_stats)
sleep 1
read -r total2 idle2 < <(read_cpu_stats)

if [[ -n "$total1" && -n "$total2" ]] && (( total2 > total1 )); then
    awk -v t1="$total1" -v t2="$total2" \
        -v i1="$idle1" -v i2="$idle2" \
        'BEGIN {
            usage = 100 * ((t2-t1)-(i2-i1))/(t2-t1)
            printf "Total CPU Usage: %.2f%%\n", usage
        }'
else
    echo "CPU usage: Unable to calculate"
fi

# Memory usage
print_section "MEMORY USAGE"

free -b | awk '
    /^Mem:/ {
        total = $2
        available = $7
        used = total - available

        if (total > 0) {
            printf "Total:     %.2f GiB\n", total/1073741824
            printf "Used:      %.2f GiB (%.2f%%)\n",
                   used/1073741824, used*100/total
            printf "Available: %.2f GiB (%.2f%%)\n",
                   available/1073741824, available*100/total
        }
    }
'

# Disk usage
print_section "DISK USAGE"

df -hP -x tmpfs -x devtmpfs -x squashfs

# Top 5 processes by CPU
print_section "TOP 5 PROCESSES BY CPU"

ps -eo pid,comm,%cpu,%mem --sort=-%cpu | awk 'NR == 1 {print; next} $2 !~ /^(ps|awk|head)$/ {print; count++; if (count == 5) exit}'

# Top 5 processes by memory
print_section "TOP 5 PROCESSES BY MEMORY"

ps -eo pid,comm,%mem,%cpu --sort=-%mem | awk 'NR == 1 {print; next} $2 !~ /^(ps|awk|head)$/ {print; count++; if (count == 5) exit}'

# Logged-in users
print_section "LOGGED-IN USERS"

who

echo
echo "Server statistics report completed."
