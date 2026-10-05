# SSH Hardening Notes

## Configuration Locations

- Active server file: `/etc/ssh/sshd_config.d/00-hardening.conf`
- Repository copy: `configs/sshd_config.d/00-hardening.conf`

## Changes and Reasons

### `PubkeyAuthentication yes`

Enables SSH key authentication for the named administrator.

### `PasswordAuthentication no`

Disables reusable SSH passwords and reduces exposure to password guessing.

### `KbdInteractiveAuthentication no`

Closes an additional interactive authentication path.

### `PermitEmptyPasswords no`

Explicitly refuses accounts with empty passwords.

### `PermitRootLogin no`

Prevents direct root access and requires administrators to use an identified account.

### `MaxAuthTries 3`

Limits authentication attempts within each SSH connection.

### `X11Forwarding no`

Disables remote graphical forwarding because the server does not require it.

### `AllowAgentForwarding no`

Prevents forwarded client SSH agents from being used through the server.

### `AllowTcpForwarding no`

Prevents the SSH connection from being used as a TCP tunnel.

### `AllowUsers devopsadmin`

Allows new SSH sessions only for the verified named administrator.

## Safe Deployment Process

1. Install the administrator's public key.
2. Verify a fresh key-based login.
3. Validate syntax with `sudo sshd -t`.
4. Inspect effective values with `sudo sshd -T`.
5. Keep the existing administrative session open.
6. Restart SSH and test a second fresh connection.
7. Confirm password, root and default-account logins are refused.
8. Enable UFW only after allowing OpenSSH.
9. Repeat the acceptance tests.

## Verified Results

- SSH configuration syntax was valid.
- Effective values matched the intended policy.
- `devopsadmin` key login succeeded through active UFW.
- Restricted sudo remained functional.
- Password, root and default `ubuntu` logins were refused.

## Recovery Lesson

`AllowUsers devopsadmin` immediately blocks new sessions for every other account. Root-level setup should be completed before the original administrative session is closed, and a second verified connection should remain available during testing.
