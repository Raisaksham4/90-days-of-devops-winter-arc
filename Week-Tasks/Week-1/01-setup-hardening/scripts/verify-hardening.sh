#!/usr/bin/env bash

set -uo pipefail

PASS_COUNT=0
FAIL_COUNT=0

pass() {
    echo "PASS: $1"
    ((PASS_COUNT += 1))
}

fail() {
    echo "FAIL: $1"
    ((FAIL_COUNT += 1))
}

run_check() {
    local message=$1
    shift

    if "$@" >/dev/null 2>&1; then
        pass "$message"
    else
        fail "$message"
    fi
}

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: Run this script with sudo."
    exit 1
fi

echo "========== FINAL HARDENING VERIFICATION =========="

echo
echo "=== USERS AND GROUPS ==="

run_check "devopsadmin exists" id devopsadmin
run_check "appsvc service account exists" id appsvc

if id -nG devopsadmin | tr ' ' '\n' | grep -qx appops; then
    pass "devopsadmin belongs to appops"
else
    fail "devopsadmin does not belong to appops"
fi

if id -nG appsvc | tr ' ' '\n' | grep -qx appops; then
    pass "appsvc belongs to appops"
else
    fail "appsvc does not belong to appops"
fi

if getent passwd appsvc | awk -F: '$7 == "/usr/sbin/nologin" { found=1 } END { exit !found }'; then
    pass "appsvc uses the nologin shell"
else
    fail "appsvc does not use the nologin shell"
fi

echo
echo "=== SUDO POLICY ==="

run_check \
    "devopsadmin sudoers syntax is valid" \
    visudo -cf /etc/sudoers.d/devopsadmin

run_check \
    "allowed SSH validation command works" \
    sudo -u devopsadmin sudo -n /usr/sbin/sshd -t

if sudo -u devopsadmin sudo -n /usr/bin/id >/dev/null 2>&1; then
    fail "command outside the sudo policy was allowed"
else
    pass "command outside the sudo policy was refused"
fi

echo
echo "=== APPLICATION DIRECTORY ==="

EXPECTED_PERMISSIONS="2770 appsvc appops"
ACTUAL_PERMISSIONS=$(stat -c '%a %U %G' /opt/devops-app)

if [[ $ACTUAL_PERMISSIONS == "$EXPECTED_PERMISSIONS" ]]; then
    pass "/opt/devops-app has mode 2770 and correct ownership"
else
    fail "/opt/devops-app permissions are: $ACTUAL_PERMISSIONS"
fi

APPSVC_TEST="/opt/devops-app/.appsvc-verification"
ADMIN_TEST="/opt/devops-app/.admin-verification"
UNAUTHORIZED_TEST="/opt/devops-app/.unauthorized-verification"

if sudo -u appsvc touch "$APPSVC_TEST"; then
    pass "appsvc can write to the application directory"
else
    fail "appsvc cannot write to the application directory"
fi

if sudo -u devopsadmin touch "$ADMIN_TEST"; then
    pass "devopsadmin can write through appops membership"
else
    fail "devopsadmin cannot write through appops membership"
fi

if sudo -u nobody touch "$UNAUTHORIZED_TEST" >/dev/null 2>&1; then
    fail "unauthorized user could write to the application directory"
else
    pass "unauthorized user was denied"
fi

rm -f "$APPSVC_TEST" "$ADMIN_TEST" "$UNAUTHORIZED_TEST"

echo
echo "=== SSH HARDENING ==="

run_check "SSH configuration syntax is valid" sshd -t

EFFECTIVE_SSH_CONFIG=$(sshd -T)

for SETTING in \
    "permitrootlogin no" \
    "pubkeyauthentication yes" \
    "passwordauthentication no" \
    "kbdinteractiveauthentication no" \
    "permitemptypasswords no" \
    "maxauthtries 3" \
    "x11forwarding no" \
    "allowagentforwarding no" \
    "allowtcpforwarding no" \
    "allowusers devopsadmin"
do
    if grep -qx "$SETTING" <<< "$EFFECTIVE_SSH_CONFIG"; then
        pass "SSH setting: $SETTING"
    else
        fail "SSH setting missing: $SETTING"
    fi
done

echo
echo "=== FIREWALL AND LISTENER ==="

if ufw status | grep -q '^Status: active'; then
    pass "UFW is active"
else
    fail "UFW is not active"
fi

if ufw status | grep -Eq '^(22/tcp|OpenSSH).*ALLOW'; then
    pass "UFW allows SSH"
else
    fail "UFW does not show an SSH allow rule"
fi

if ss -ltn | awk '$4 ~ /:22$/ { found=1 } END { exit !found }'; then
    pass "SSH is listening on TCP port 22"
else
    fail "SSH is not listening on TCP port 22"
fi

echo
echo "========== VERIFICATION SUMMARY =========="
echo "Passed: $PASS_COUNT"
echo "Failed: $FAIL_COUNT"

if (( FAIL_COUNT > 0 )); then
    exit 1
fi

echo "RESULT: HARDENING VERIFICATION PASSED"
