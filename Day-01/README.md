# Day 1 — Linux Foundations

## Status

✅ Completed

## Objective

Learn the Linux filesystem, practise essential commands, inspect users and groups,
manage file ownership and permissions, monitor system resources, use APT package
management, and execute a Bash script.

## Topics Covered

- Linux filesystem navigation
- Hidden files and directories
- Creating, copying, moving, and reading files
- Linux users, groups, UID, GID, home directory, and login shell
- File ownership and permission management
- Memory, disk, and process monitoring
- APT package inspection and repository metadata updates
- Package installation, verification, and removal
- Reading, validating, and executing Bash scripts

## Commands Practised

| Command | Purpose |
|---|---|
| `whoami` | Display the current Linux user |
| `id` | Display UID, GID, and group memberships |
| `groups` | List groups for the current user |
| `getent passwd "$USER"` | Display the current user's account entry |
| `pwd` | Print the current working directory |
| `ls` | List directory contents |
| `ls -la` | List all files with permissions and details |
| `cd` | Change the current directory |
| `cd ..` | Move to the parent directory |
| `touch` | Create an empty file or update its timestamp |
| `cat` | Display file contents |
| `cat -n` | Display file contents with line numbers |
| `echo` | Print text or variable values |
| `cp` | Copy files and directories |
| `mv` | Move or rename files and directories |
| `chmod` | Change file permissions |
| `chgrp` | Change a file's group ownership |
| `free -h` | Display memory usage in a readable format |
| `du -h` | Display file and directory disk usage |
| `df -h` | Display filesystem space usage |
| `ps` / `ps aux` | Display running processes |
| `top` | Monitor processes and resource usage interactively |
| `tree` | Display a directory structure |
| `apt --version` | Display the installed APT version |
| `apt list --installed` | List installed packages |
| `apt-cache policy` | Inspect installed and candidate package versions |
| `sudo apt update` | Refresh package repository metadata |
| `sudo apt install` | Install a package |
| `dpkg -l` | Verify a package through the dpkg database |
| `sudo apt remove` | Remove an installed package |
| `bash -n` | Check a Bash script for syntax errors |

## File Permissions and Ownership

I inspected Linux permission strings and practised changing permissions and group
ownership on a demonstration file.

Example directory permission:

```text
drwxr-xr-x
```

Example file permission:

```text
-rw-r--r--
```

I changed the demonstration file to permission mode `640`:

```text
-rw-r-----
```

Mode `640` gives the owner read and write access, the group read access, and
other users no access.

Commands used:

```bash
touch Day-01/ownership-demo.txt
chmod 640 Day-01/ownership-demo.txt
chgrp users Day-01/ownership-demo.txt
ls -l Day-01/ownership-demo.txt
```

## Users and Groups

I inspected the current user's identity, primary group, supplementary groups,
home directory, and login shell.

```bash
id
groups
getent passwd "$USER"
```

This exercise demonstrated how Linux associates users with numeric UIDs, primary
GIDs, supplementary groups, home directories, and login shells.

## Package Management Exercise

I completed the APT package lifecycle using `cowsay` as a demonstration package:

1. Inspected the APT version and existing package information.
2. Refreshed repository metadata with `sudo apt update`.
3. Checked the package candidate with `apt-cache policy cowsay`.
4. Installed the package with `sudo apt install cowsay`.
5. Executed the installed program successfully.
6. Verified installation with `dpkg -l cowsay`.
7. Removed it with `sudo apt remove cowsay`.
8. Confirmed removal with `apt-cache policy cowsay`.

The final policy output showed `Installed: (none)`, confirming successful removal.

## Implementation

```text
Day-01/
├── README.md
├── disk_usage.txt
├── file-copy-using-cp.txt
├── file-renamed-using-mv.txt
├── free_memory_using_free-h.txt
├── id_and_group_membership.txt
├── ownership-demo.txt
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
| `id_and_group_membership.txt` | User identity and group membership output |
| `ownership-demo.txt` | Demonstration file used for permissions and ownership |
| `running_processes.txt` | Running process information |
| `scripts/system-info.sh` | Bash script for displaying system information |

## Script Verification

The Bash script was checked for syntax errors:

```bash
bash -n scripts/system-info.sh
```

It was then executed successfully:

```bash
bash scripts/system-info.sh
```

## Key Learnings

- Linux uses a hierarchical filesystem.
- `.` represents the current directory and `..` represents its parent.
- Files beginning with `.` are hidden by default.
- Users are identified by UIDs and belong to primary and supplementary groups.
- Permissions control read, write, and execute access for owners, groups, and others.
- Ownership and permissions can be managed with `chgrp` and `chmod`.
- `free`, `du`, `df`, `ps`, and `top` help inspect system resources.
- APT refreshes metadata, installs packages, and removes packages.
- `dpkg -l` verifies the installation state stored in the package database.
- Bash scripts combine commands into repeatable workflows and should be validated before execution.

## Reflection

Day 1 provided practical experience with Linux navigation, file operations, users,
groups, ownership, permissions, system monitoring, package management, and Bash
scripting. These fundamentals support future work with Linux servers, containers,
CI/CD pipelines, and cloud infrastructure.
