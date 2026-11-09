# Log Archive Tool

A Bash-based utility for archiving log directories into compressed `.tar.gz` files. It provides input validation, archive integrity verification, restrictive file permissions, execution logging, and automated scheduling through Cron.

## Project Page

Project URL: https://roadmap.sh/projects/log-archive-tool

## Features

- Accepts a log directory as a command-line argument.
- Validates input paths and directory permissions.
- Creates compressed archives in `.tar.gz` format.
- Generates timestamp-based archive filenames.
- Prevents overwriting existing archives.
- Uses temporary files during archive creation.
- Verifies archive integrity using `gzip -t`.
- Applies restrictive file permissions using `umask 077`.
- Records successful archive operations in a log file.
- Supports automated daily execution through Cron.
- Captures Cron execution output and errors in a separate log file.
- Preserves original source log files after archiving.

## Requirements

- Linux operating system
- Bash
- GNU tar
- gzip
- Cron (for scheduled execution)

## Project Structure

```text
log-archive/
├── archives/
│   └── .gitkeep
├── test-logs/
│   ├── application/
│   │   └── app.log
│   ├── messages
│   ├── secure
│   └── cron
├── .gitignore
├── README.md
└── log-archive.sh
```

## Usage

Run the script with the target log directory:

```bash
./log-archive.sh /path/to/log-directory
```

Example:

```bash
./log-archive.sh ./test-logs
```

Generated archives are stored in the `archives/` directory.

### Archive Naming Convention

```text
logs_archive_YYYYMMDD_HHMMSS.tar.gz
```

Example:

```text
logs_archive_20261108_230000.tar.gz
```

## Logging

The tool maintains two separate log files:

- `archives/archive.log`: Records the timestamp, source directory, archive path, and successful execution status.
- `archives/cron.log`: Captures standard output and error messages from scheduled Cron executions.

Generated archives and runtime log files are excluded from Git using `.gitignore`.

## Automated Scheduling

The tool supports daily execution through Cron.

Example Cron entry for running the archive operation every day at 23:00:

```cron
0 23 * * * /path/to/log-archive.sh /path/to/log-directory >> /path/to/cron.log 2>&1
```

Replace the example paths with the actual script, source directory, and Cron output log paths in your environment.

## Security Considerations

- Validates source and destination directories.
- Prevents the archive destination from being inside the source directory.
- Sets restrictive file permissions (`600`) for generated archives and the application log.
- Prevents accidental overwriting of existing archives.
- Preserves original source log files.

## Future Improvements

- **Retention Policy:** Automatically remove old archives based on configurable retention periods.
- **Remote Backup:** Transfer archives to remote servers or cloud storage.
- **Email Notifications:** Send notifications about successful or failed archive operations.
- **Archive Encryption:** Encrypt generated archives to protect sensitive log data.
- **Configurable Scheduling:** Allow users to configure archive schedules through a configuration file.

## Project Status

Core archive creation, input validation, integrity verification, and logging have been implemented and tested in an AlmaLinux lab environment.

A daily Cron job is configured to run the archive script at 23:00. Manual execution of the Cron command and its output redirection has been tested; the actual scheduled Cron execution is pending verification.

The project uses sample log files in a lab environment. Original source files are preserved and are not deleted after archiving.

## License

This project is licensed under the MIT License.
See the [LICENSE](../LICENSE) file for details.
