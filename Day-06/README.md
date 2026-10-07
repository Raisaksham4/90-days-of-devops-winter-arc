# Day 6 — Storage, Monitoring, and Production Debugging

## Goal

Inspect a Linux system's storage and resource usage, collect repeatable diagnostic output, and troubleshoot a web service failure using evidence from the endpoint, service manager, listening ports, and logs.

## Environment

- Ubuntu running in WSL 2 on `GalaxyBook4`
- Nginx serving HTTP on local port 80
- Observations below are snapshots from the Day 6 lab on October 7, 2026; usage and process values can change.

## Storage inspection

I used `lsblk` to identify block devices, `df -h` to check filesystem capacity, and `du -h -d 1 ~ | sort -rh` to find the largest directories in my home folder.

The WSL root filesystem was mounted from `/dev/sdd`, with approximately 947 GB available. My home directory used about 4.6 GB. Its largest directories included `.vscode-server` (about 1.9 GB) and `terraform` (about 1.7 GB). I also checked `/var/log` with `sudo du -sh /var/log`; it used about 434 MB.

`df` measures free space on a filesystem, while `du` measures space used by files and directories. Both views are useful when diagnosing a full disk.

## Resource and service monitoring

I used `uptime`, `free -h`, and `ps aux --sort=-%mem` / `ps aux --sort=-%cpu` to inspect system load, memory, and processes. At the time of capture, the load averages were `0.11`, `0.03`, and `0.01`. Memory showed 7.6 GiB total and 6.5 GiB available; 2 GiB of swap was unused. `mysqld` was the largest memory consumer in the captured process list, at about 6.5% of RAM.

I used `ss -tulpn` to inspect listening TCP and UDP sockets, and `systemctl` plus `journalctl` to inspect service state and events. The `-n` option in `ss` keeps addresses and ports numeric, making the actual listener easier to identify.

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

The output files are point-in-time evidence from my WSL environment. Rerun the scripts for current values on another machine.

## Key takeaway

When a local web endpoint fails, check the request result, service state, listening port, and logs. Restore the service, then make a new request to confirm that it works.
