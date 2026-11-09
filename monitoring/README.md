# Server Stats

A Bash-based utility for displaying essential Linux server performance and system information. It provides a terminal-based report covering CPU, memory, disk usage, running processes, and logged-in users.

## Project Page

Roadmap.sh: https://roadmap.sh/projects/server-stats

## Features

- Displays operating system information and hostname.
- Reports system uptime and load average.
- Calculates total CPU usage over a one-second sampling interval.
- Displays memory statistics, including total, used, free, and available memory with percentages.
- Reports disk usage across mounted filesystems, excluding `tmpfs`, `devtmpfs`, and `squashfs`.
- Lists the top 5 processes by CPU usage.
- Lists the top 5 processes by memory usage.
- Displays currently logged-in users.
- Checks for required system commands before execution.
- Handles unavailable CPU statistics and missing memory information.

## Requirements

- Linux operating system
- Bash
- Standard Linux utilities:
  - `awk`
  - `ps`
  - `df`
  - `free`
  - `uptime`
  - `hostname`
  - `who`
  - `sleep`

## Project Structure

```text
linux-admin-scripts/
└── monitoring/
    ├── README.md
    └── server-stats.sh
```

## Usage

Run the script from the root directory of the repository:

```bash
bash monitoring/server-stats.sh
```

The script displays a system statistics report directly in the terminal.

CPU usage is calculated by comparing CPU statistics from `/proc/stat` over a one-second interval.

## Compatibility

Developed and tested in a lab environment running AlmaLinux 10.2.

The script relies on standard Linux utilities and `/proc` system information. Other Linux distributions may work, but have not yet been verified.

## Project Status

Implemented and tested in an AlmaLinux 10.2 lab environment.

The script includes system information reporting, CPU and memory monitoring, disk usage reporting, process statistics, and logged-in user information.

## Future Improvements

- **Configurable Monitoring:** Allow users to select which system metrics to display.
- **Alerting:** Add configurable thresholds for CPU, memory, and disk usage.
- **Output Options:** Support exporting reports to text or JSON files.
- **Automated Monitoring:** Support scheduled execution and integration with monitoring systems.

## License

This project is licensed under the MIT License.
See the [LICENSE](../LICENSE) file for details.
