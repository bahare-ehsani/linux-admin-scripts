
# Linux Admin Scripts

A collection of Bash scripts for Linux system administration, monitoring, and troubleshooting.

## Project Page

GitHub repository: https://roadmap.sh/projects/server-stats

## Project Structure

```text
linux-admin-scripts/
├── monitoring/
│   └── server-stats.sh
├── README.md
└── LICENSE
```

## Available Scripts

### Monitoring

#### `monitoring/server-stats.sh`

Displays basic Linux server statistics, including:

- Operating system and hostname
- System uptime and load average
- Total CPU usage
- Memory usage: used, free, and available memory, including percentages
- Disk usage, including used and available space and usage percentage
- Top 5 processes by CPU usage
- Top 5 processes by memory usage
- Logged-in users

**Requirements:** Bash and standard Linux utilities, including `awk`, `ps`, `df`, `free`, `uptime`, `hostname`, `who`, and `sleep`.

**Usage:**

Run the following command from the repository directory:

```bash
bash monitoring/server-stats.sh
```

The script prints a system statistics report to the terminal. CPU usage is calculated over a one-second sampling interval.

## Compatibility

Developed and tested in a lab environment running AlmaLinux 10.2.

Other Linux distributions may work, but have not yet been verified.

## Project Status

This project is under active development. Additional scripts for system administration, backup, networking, and troubleshooting may be added over time.

## License

See the `LICENSE` file for licensing information.
