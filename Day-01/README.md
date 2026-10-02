# Day 1 — Linux Foundations

## Status

✅ Completed

## Objective

Learn the Linux filesystem, practise essential commands, understand file
permissions, inspect system resources, and execute a Bash script.

## Topics Covered

- Linux users and operating system information
- Filesystem navigation
- Hidden files and directories
- File and directory permissions
- Creating, copying, and renaming files
- Memory and disk monitoring
- Viewing running processes
- Reading and executing Bash scripts

## Commands Practised

| Command | Purpose |
|---|---|
| `whoami` | Display the current Linux user |
| `pwd` | Show the current working directory |
| `cat /etc/os-release` | Display operating system information |
| `ls` | List directory contents |
| `ls -la` | List all files with permissions and details |
| `cd` | Change the current directory |
| `cd ..` | Move to the parent directory |
| `cat` | Display file contents |
| `cat -n` | Display file contents with line numbers |
| `cp` | Copy files |
| `mv` | Move or rename files |
| `free -h` | Display memory usage in a readable format |
| `df -h` | Display disk usage in a readable format |
| `ps aux` | Display running processes |
| `tree` | Display the directory structure |
| `bash -n` | Check a Bash script for syntax errors |

## File Permissions

Example directory permission:

```text
drwxr-xr-x
```

- `d` indicates a directory.
- `rwx` means the owner can read, write, and enter the directory.
- `r-x` means the group can read and enter the directory.
- `r-x` means other users can read and enter the directory.

Example file permission:

```text
-rw-r--r--
```

- `-` indicates a regular file.
- `rw-` means the owner can read and write.
- `r--` means the group can only read.
- `r--` means other users can only read.

## Implementation

I created files containing the output of common Linux operations and system
monitoring commands.

```text
Day-01/
├── README.md
├── disk_usage.txt
├── file-copy-using-cp.txt
├── file-renamed-using-mv.txt
├── free_memory_using_free-h.txt
├── running_processes.txt
└── scripts/
    └── system-info.sh
```

### Evidence Files

| File | Description |
|---|---|
| `disk_usage.txt` | Disk usage information |
| `file-copy-using-cp.txt` | File created using the `cp` command |
| `file-renamed-using-mv.txt` | File renamed using the `mv` command |
| `free_memory_using_free-h.txt` | System memory usage |
| `running_processes.txt` | List of running processes |
| `scripts/system-info.sh` | Bash script for displaying system information |

## Script Verification

The Bash script was checked for syntax errors:

```bash
bash -n scripts/system-info.sh
```

The script was then executed successfully:

```bash
bash scripts/system-info.sh
```

## Key Learnings

- Linux uses a hierarchical filesystem.
- `.` represents the current directory and `..` represents the parent directory.
- Files beginning with `.` are hidden by default.
- Linux permissions control read, write, and execute access.
- Commands such as `free`, `df`, and `ps` help monitor a system.
- Bash scripts can combine multiple commands into a repeatable workflow.
- Scripts should be syntax checked and tested before being committed.

## Reflection

Day 1 gave me practical experience with Linux navigation, file operations,
permissions, system monitoring, and Bash script execution. These fundamentals
will support later work with servers, containers, CI/CD pipelines, and cloud
infrastructure.
