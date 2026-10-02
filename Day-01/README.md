# Day 1/90 - Linux Foundations

## Objective

Understand the Linux filesystem and practise essential commands for navigation,
file management, searching, system inspection, and process inspection.

## Checklist

- [ ] Explore `/home`, `/etc`, `/var`, `/tmp`, `/usr`, and `/opt`
- [ ] Practise `pwd`, `ls`, `cd`, `mkdir`, `touch`, `cp`, `mv`, and `cat`
- [ ] Search with `grep` and `find`
- [ ] Inspect disk usage with `df -h`
- [ ] Inspect memory usage with `free -h`
- [ ] Inspect running processes with `ps` and `top`
- [ ] Run and understand the system information script
- [ ] Record errors, fixes, and key learnings

## Implementation

The `scripts/system-info.sh` script collects basic information about the Linux
environment:

- Current user
- Hostname
- Operating system
- Root filesystem usage
- Memory usage
- System uptime

Run it with:

```bash
chmod +x scripts/system-info.sh
./scripts/system-info.sh
```

Save its output as evidence:

```bash
./scripts/system-info.sh > system-info.txt
```

## Commands Practised

This section will be updated after completing the exercises.

## Errors and Fixes

This section will record problems encountered during implementation and how
they were resolved.

## Key Learnings

This section will be completed at the end of Day 1.

## Related Documentation

- Detailed notes: Notion Day 1 entry
- Daily summary: LinkedIn Day 1/90 update

