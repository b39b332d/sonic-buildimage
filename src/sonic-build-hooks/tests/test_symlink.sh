#!/bin/bash
# test_symlink.sh - Test symlink_build_hooks creates correct symlinks

set -e

cd /root/sonic-build-hooks
rpm -ivh buildinfo/sonic-build-hooks-1.0-1.noarch.rpm > /dev/null

echo "Running symlink_build_hooks..."
bash /usr/local/share/buildinfo/scripts/symlink_build_hooks

EXPECTED_HOOKS="dnf rpm pip3"

for hook in $EXPECTED_HOOKS; do
    if [ -L "/usr/local/sbin/$hook" ]; then
        target=$(readlink /usr/local/sbin/$hook)
        if echo "$target" | grep -q "buildinfo/hooks/$hook"; then
            echo "  /usr/local/sbin/$hook -> $target (OK)"
        else
            echo "FAIL: /usr/local/sbin/$hook points to wrong target: $target"
            rpm -e sonic-build-hooks > /dev/null 2>&1
            exit 1
        fi
    else
        echo "FAIL: /usr/local/sbin/$hook symlink not found"
        rpm -e sonic-build-hooks > /dev/null 2>&1
        exit 1
    fi
done

# Cleanup
rpm -e sonic-build-hooks > /dev/null 2>&1

echo "PASS"
