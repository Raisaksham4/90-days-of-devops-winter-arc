# Week 1 Task 1 — Linux Server Setup & Hardening

## Status

✅ Completed and verified on an Ubuntu 26.04 LTS Amazon EC2 instance.

## Goal

Turn a fresh Linux server into a restricted host with:

- Named administrative and service accounts
- SSH key authentication
- Disabled root and password-based SSH login
- Least-privilege sudo rules
- Controlled application-directory permissions
- An active firewall permitting SSH only
- Automated verification and recorded evidence

## Accounts and Groups

| Account or group | Purpose |
|---|---|
| `devopsadmin` | Named interactive administrator |
| `appsvc` | Non-interactive application service account |
| `appops` | Shared application operations group |

The `appsvc` account uses `/usr/sbin/nologin`. Both accounts belong to `appops`.

## Least-Privilege Sudo

`devopsadmin` can validate and maintain SSH through an explicit sudo policy. A command outside that policy was tested and refused.

The reusable policy is stored at `configs/sudoers.d/devopsadmin`.

## Application Directory Permissions

`/opt/devops-app` was configured as:

```text
drwxrws--- 2770 appsvc:appops
```

The setgid bit makes new files inherit the `appops` group. Tests confirmed that `appsvc` and `devopsadmin` can write while an unauthorized user is denied.

## SSH Hardening

The reusable configuration is stored at `configs/sshd_config.d/00-hardening.conf`.

Implemented controls:

- Public-key authentication enabled
- Password and keyboard-interactive authentication disabled
- Empty passwords refused
- Direct root login disabled
- Authentication attempts limited to three
- X11, agent and TCP forwarding disabled
- Only `devopsadmin` allowed to connect

See [ssh-hardening-notes.md](ssh-hardening-notes.md) for every setting and its purpose.

## Firewall

UFW denies incoming traffic by default, allows outgoing traffic and explicitly allows OpenSSH. A fresh `devopsadmin` connection succeeded after UFW was enabled.

## Automated Verification

Run:

```bash
sudo ./scripts/verify-hardening.sh
```

Final result:

```text
Passed: 26
Failed: 0
RESULT: HARDENING VERIFICATION PASSED
```

## Acceptance Tests

| Test | Result |
|---|---|
| `devopsadmin` key login | PASS |
| Restricted sudo | PASS |
| Password SSH login | REFUSED |
| Root SSH login | REFUSED |
| Default `ubuntu` SSH login | REFUSED |
| Unauthorized directory write | REFUSED |
| SSH through active UFW | PASS |

## Repository Contents

- `configs/` — reusable SSH and sudo policies
- `scripts/` — permission setup and final verification
- `evidence/` — command output captured during implementation
- `ssh-hardening-notes.md` — every SSH change and its reason

## Recovery Lesson

The final `AllowUsers devopsadmin` rule was initially applied before all root-level work was complete, and the original administrator session was closed.

Access was recovered by creating an EBS snapshot, attaching the root volume to a temporary rescue instance, temporarily permitting `ubuntu`, returning the volume, completing the firewall work and restoring the final named-admin-only policy.

This demonstrated why SSH changes should be applied incrementally while an existing administrative session remains open.

## Security Notes

This repository contains no private SSH keys, PEM files, passwords, AWS credentials or public EC2 addresses.
