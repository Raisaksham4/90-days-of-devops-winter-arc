# Day 2 — Bash Scripting Fundamentals

## Objective

Learn the foundations of Bash scripting and use them to automate common Linux and DevOps tasks.

## Topics Covered

- Bash variables
- Command substitution
- User input with `read`
- Conditional statements
- Arrays and loops
- Functions
- Script arguments
- Exit codes
- Syntax validation
- Directory backups using `tar`

## Scripts Created

### 1. `system-summary.sh`

Displays basic system information using variables and command substitution:

- Current user
- Working directory
- Current date
- Kernel version

### 2. `user_input_script.sh`

Accepts a name and DevOps topic from the user, stores them in variables, and prints a personalised message.

### 3. `disk_check.sh`

Checks the root filesystem usage and uses an `if` statement to report whether it has crossed the configured 80% warning threshold.

### 4. `service_check.sh`

Uses an array and a `for` loop to check the status of:

- SSH
- Cron
- Docker

The script reports whether each service is running.

### 5. `health_report.sh`

Uses reusable Bash functions to generate a system health report containing:

- Generation date
- Disk usage
- Memory usage
- System uptime

### 6. `backup_directory.sh`

Accepts a directory as a command-line argument and creates a timestamped compressed backup.

It also demonstrates:

- `$1` for the first argument
- `$0` for the script name
- `$?` for the previous command's exit code
- Custom exit codes for different failure cases

## Project Structure

```text
Day-02/
├── README.md
├── .gitignore
├── syntax-validation.sh
├── syntax-validation.txt
├── backups/
└── scripts/
    ├── backup_directory.sh
    ├── disk_check.sh
    ├── health_report.sh
    ├── service_check.sh
    ├── system-summary.sh
    └── user_input_script.sh
```

The generated `backups/` directory is excluded from Git tracking.

## Validation

Every script was checked with:

```bash
bash -n <script-name>
```

All six scripts passed Bash syntax validation.

## Debugging Lessons

### Variable assignments cannot contain spaces

Correct:

```bash
current_user=$(whoami)
```

Incorrect:

```bash
current_user = $(whoami)
```

With spaces, Bash interprets the variable name as a command.

### Test brackets require spaces

Correct:

```bash
if [ "$status" -eq 0 ]; then
```

Incorrect:

```bash
if [ "$status" -eq 0]; then
```

### Capture exit codes immediately

```bash
tar -czf "$backup_file" "$source_directory"
tar_status=$?
```

This preserves the result of the `tar` command before another command changes `$?`.

### Verify commands independently

When the service-check script failed because of a typo, running `systemctl status docker` separately confirmed that Docker and `systemctl` were available.

## Key Learnings

- Bash variables store reusable values and command output.
- Quoting variables helps prevent word splitting and path-related errors.
- Conditionals allow scripts to make decisions from system data.
- Arrays and loops automate repeated checks.
- Functions make scripts easier to read and maintain.
- Arguments make scripts reusable for different inputs.
- Exit codes communicate success or specific failure conditions.
- `bash -n` catches syntax errors without executing a script.
- Testing error and success paths makes automation more reliable.

## Outcome

Built and validated six Bash scripts that perform system inspection, user interaction, disk monitoring, service checks, health reporting, and timestamped backups.

## Next Step

Day 3 — Continue building Linux and Bash automation skills through practical tasks.
