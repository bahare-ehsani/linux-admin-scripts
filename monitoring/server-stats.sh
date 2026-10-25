#!/usr/bin/env bash

# server-stats.sh
# Displays basic Linux server performance statistics.

set -o pipefail

print_section() {
    printf '\n========== %s ==========\n' "$1"
}

# Check required commands
for cmd in awk ps df free uptime hostname who sleep; do
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
else
    printf 'OS: Unknown\n'
fi

printf 'Hostname: %s\n' "$(hostname)"

printf 'Uptime: '
uptime -p 2>/dev/null || uptime

printf 'Load Average: '
if [[ -r /proc/loadavg ]]; then
    awk '{print $1, $2, $3}' /proc/loadavg
else
    printf 'Unavailable\n'
fi

# CPU usage over a one-second sampling interval
print_section "CPU USAGE"

read_cpu_stats() {
    awk '/^cpu / {
        idle = $5 + $6
        total = 0
        for (i = 2; i <= 9 && i <= NF; i++) {
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
            elapsed = t2 - t1
            idle_delta = i2 - i1
            usage = 100 * (elapsed - idle_delta) / elapsed

            if (usage < 0) usage = 0
            if (usage > 100) usage = 100

            printf "Total CPU Usage: %.2f%%\n", usage
        }'
else
    printf 'CPU usage: Unable to calculate\n'
fi

# Memory usage
print_section "MEMORY USAGE"

free -b | awk '
    /^Mem:/ {
        total = $2
        used = $3
        free_mem = $4
        available = $7

        if (total > 0) {
            printf "Total:     %.2f GiB\n", total / 1073741824
            printf "Used:      %.2f GiB (%.2f%%)\n",
                   used / 1073741824, used * 100 / total
            printf "Free:      %.2f GiB (%.2f%%)\n",
                   free_mem / 1073741824, free_mem * 100 / total
            printf "Available: %.2f GiB (%.2f%%)\n",
                   available / 1073741824, available * 100 / total
        }

        found = 1
    }

    END {
        if (!found) {
            print "Error: Unable to read memory statistics." > "/dev/stderr"
            exit 1
        }
    }
'

# Disk usage
print_section "DISK USAGE"
printf 'Avail indicates available free space; Use%% indicates percentage used.\n'
df -hP -x tmpfs -x devtmpfs -x squashfs

# Top 5 processes by CPU usage
print_section "TOP 5 PROCESSES BY CPU"

ps -eo pid,comm,%cpu,%mem --sort=-%cpu |
    awk 'NR == 1 {print; next}
         $2 !~ /^(ps|awk)$/ {
             print
             count++
             if (count == 5) exit
         }'

# Top 5 processes by memory usage
print_section "TOP 5 PROCESSES BY MEMORY"

ps -eo pid,comm,%mem,%cpu --sort=-%mem |
    awk 'NR == 1 {print; next}
         $2 !~ /^(ps|awk)$/ {
             print
             count++
             if (count == 5) exit
         }'

# Logged-in users
print_section "LOGGED-IN USERS"
who

printf '\nServer statistics report completed.\n'
