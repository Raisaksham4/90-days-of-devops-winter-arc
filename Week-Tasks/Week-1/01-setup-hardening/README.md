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

The `appsvc` account uses `/usr/sbin/nologin`, preventing interactive login.

Both `devopsadmin` and `appsvc` belong to `appops`.

## Least-Privilege Sudo

`devopsadmin` can run only these administrative commands without a password:

- Validate the SSH configuration
- View SSH service status
- Restart the SSH service
- View SSH service logs

A command outside this policy was tested and refused.

The reusable sudo policy is stored at:

```text
configs/sudoers.d/devopsadmin
