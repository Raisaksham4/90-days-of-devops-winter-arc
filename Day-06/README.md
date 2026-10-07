# Day 6 — Storage, Monitoring, and Production Debugging

## Goal

Inspect Linux storage and resource usage, mount a safe test filesystem, troubleshoot a controlled near-full condition, and verify recovery. I also practiced diagnosing a stopped Nginx service.

## Environment

- Ubuntu running in WSL 2 on `GalaxyBook4`
- Nginx serving HTTP on local port 80
- Observations below are snapshots from the Day 6 lab on October 7, 2026; usage and process values can change.

## Storage inspection

I used `lsblk` to identify block devices, `df -h` to check filesystem capacity, and `du -h -d 1 ~ | sort -rh` to find the largest directories in my home folder.

The WSL root filesystem was mounted from `/dev/sdd` as ext4, with approximately 947 GB available. My home directory used about 4.6 GB. Its largest directories included `.vscode-server` (about 1.9 GB) and `terraform` (about 1.7 GB). Under `/var`, `/var/lib` used about 1.2 GB, `/var/log` 434 MB, and `/var/cache` 220 MB.

`df` measures free space on a filesystem, while `du` measures space used by files and directories. Both views are useful when diagnosing a full disk.

The disk image or device stores blocks; ext4 organizes those blocks into files and directories; a mount point makes that filesystem accessible at a path. A UUID identifies a filesystem independently of a changing loop device number.

## Safe test filesystem and persistent mount

I created a 100 MB regular file at `/var/lib/day6/day6-disk.img`, formatted that file as ext4, and mounted it with `-o loop` at `/mnt/day6disk`. I did not format a physical or WSL root device. `findmnt` showed `/dev/loop0` mounted at the target, and `df -h /mnt/day6disk` initially showed a 90 MB filesystem with 83 MB available. The difference from the 100 MB image reflects ext4 filesystem structures and reserved space.

I backed up `/etc/fstab` and added the test filesystem by its UUID (`5902f151-286b-4c71-baf5-1b79306e10d1`). After `systemctl daemon-reload`, I unmounted the test filesystem, ran `mount -a`, and confirmed the mount returned with `findmnt`. `findmnt --verify` then reported no errors or warnings. Automatic mounting after a WSL restart was not tested.

## Controlled near-full incident

I wrote only to `/mnt/day6disk`, checking that it remained an ext4 mount before the second write.

| Checkpoint | Used | Available | Use |
|---|---:|---:|---:|
| Empty test filesystem | 152 KB | 83 MB | 1% |
| After 40 MiB `testfile` | 41 MB | 43 MB | 49% |
| After another 40 MiB `fill1` | 81 MB | 2.6 MB | 97% |
| After removing both test files | 152 KB | 83 MB | 1% |

`du -ah /mnt/day6disk` identified `testfile` and `fill1` as the two 40 MB files. `df -i` showed only 14 of 25,600 inodes used, so the near-full condition was caused by data blocks rather than inode exhaustion. `lsof +L1` found unrelated zero-byte deleted MySQL temporary files under `/tmp`; it did not explain the test filesystem's usage.

I stopped at 97% instead of writing more. No application write failure or `No space left on device` error was observed. I removed only the two files created for this lab and verified the available space returned to 83 MB. The complete evidence-to-fix sequence is in [incident-report.md](./incident-report.md).

## Resource and service monitoring

I used `uptime`, `free -h`, and `ps aux --sort=-%mem` / `ps aux --sort=-%cpu` to inspect system load, memory, and processes. At the time of capture, the load averages were `0.11`, `0.03`, and `0.01`. Memory showed 7.6 GiB total and 6.5 GiB available; 2 GiB of swap was unused. `mysqld` was the largest memory consumer in the captured process list, at about 6.5% of RAM.

I used `ss -tulpn` to inspect listening TCP and UDP sockets, and `systemctl` plus `journalctl` to inspect service state and events. `systemctl --failed` listed zero failed units. The `-n` option in `ss` keeps addresses and ports numeric, making the actual listener easier to identify.

## Nginx failure and recovery lab

I simulated a local web service outage and checked each layer before restoring service:

| Step | Observation |
|---|---|
| Healthy endpoint | `curl -I http://127.0.0.1` returned `HTTP/1.1 200 OK`; Nginx was `active`. |
| Stop service | `sudo systemctl stop nginx` made the service `inactive`. |
| Confirm impact | `curl -I http://127.0.0.1` failed to connect; port 80 was not listening. |
| Inspect logs | `journalctl -u nginx --since "2026-10-07 15:50:00" --no-pager` recorded Nginx stopping at 15:55:19. |
| Recover | `sudo systemctl start nginx` restarted the service at 15:56:14, and `curl -I` returned `HTTP/1.1 200 OK` again. |

This lab showed how a failed HTTP request, service state, listening port, and journal events together identify a stopped web server. The recovery was verified with a fresh request.

## Files

| File | Purpose |
|---|---|
| `storage_cmd.sh` | Collects storage and memory information. |
| `storage_output.txt` | Captured output from the storage script. |
| `process_cmd.sh` | Collects uptime, process, memory, and listener information. |
| `process_output.txt` | Captured output from the process script. |
| `monitoring_cmd.sh` | Collects monitoring observations. |
| `monitoring_output.txt` | Captured output from the monitoring script. |
| `services_logs.sh` | Collects service and log information. |
| `nginx_logs_output.txt` | Captured Nginx log output. |
| `listeners_output.txt` | Captured listening socket output. |
| `incident-report.md` | Controlled storage incident, evidence, fix, and verification. |

The output files are point-in-time evidence from my WSL environment. Rerun the scripts for current values on another machine.

## Key takeaway

For storage incidents, use `df` to confirm the affected filesystem, `df -i` to separate block usage from inode usage, and `du` to find the files. After a narrow fix, check `df` again. For service incidents, inspect the endpoint, service state, listener, and logs, then retry the request after recovery.
