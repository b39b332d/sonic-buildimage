#!/bin/bash
# test_dnf_hook.sh - Test the dnf hook intercepts commands correctly

set -e

cd /root/sonic-build-hooks
rpm -ivh buildinfo/sonic-build-hooks-1.0-1.noarch.rpm > /dev/null

# Setup environment
export BUILDINFO_PATH=/usr/local/share/buildinfo
export VERSION_PATH=$BUILDINFO_PATH/versions
export LOG_PATH=$BUILDINFO_PATH/log
export PKG_CACHE_PATH=/tmp/test_cache
export IMAGENAME="test-hook"
export SONIC_VERSION_CONTROL_COMPONENTS=rpm
export ENABLE_VERSION_CONTROL_RPM=y
export ENABLE_VERSION_CONTROL_PY3=y
export ENABLE_VERSION_CONTROL_WEB=n
export SONIC_VERSION_CACHE=
export PACKAGE_URL_PREFIX=
export DISTRO=openeuler
export PIP_HTTP_TIMEOUT=120

mkdir -p $VERSION_PATH $LOG_PATH $PKG_CACHE_PATH $BUILDINFO_PATH/config

cat > $BUILDINFO_PATH/config/buildinfo.config << 'EOF'
export SONIC_VERSION_CONTROL_COMPONENTS=rpm,py3,web
export ENABLE_VERSION_CONTROL_RPM=y
export ENABLE_VERSION_CONTROL_PY3=y
export ENABLE_VERSION_CONTROL_WEB=n
export PACKAGE_URL_PREFIX=
export DISTRO=openeuler
export SONIC_VERSION_CACHE=
export PIP_HTTP_TIMEOUT=120
EOF

# Create symlinks (as pre_run_buildinfo would do)
bash /usr/local/share/buildinfo/scripts/symlink_build_hooks

# Verify symlink was created
if [ ! -L /usr/local/sbin/dnf ]; then
    echo "FAIL: /usr/local/sbin/dnf symlink not created by symlink_build_hooks"
    rpm -e sonic-build-hooks > /dev/null 2>&1
    exit 1
fi
echo "/usr/local/sbin/dnf -> $(readlink /usr/local/sbin/dnf)"

# Verify PATH includes /usr/local/sbin
export PATH="/usr/local/sbin:$PATH"

# Test that hook is found
WHICH_DNF=$(which dnf)
if echo "$WHICH_DNF" | grep -q "usr/local/sbin"; then
    echo "Hook dnf is found in PATH: $WHICH_DNF"
else
    echo "FAIL: hook dnf not in PATH (which dnf = $WHICH_DNF)"
    rpm -e sonic-build-hooks > /dev/null 2>&1
    exit 1
fi

# Test that the hook passes through to real dnf
echo "Testing hook passthrough..."
# dnf --version should work through the hook
# Use file redirect instead of $() to avoid exec-in-subshell issues
timeout 10 dnf --version > /tmp/hook_output.txt 2>&1
DNF_EXIT=$?
if [ $DNF_EXIT -eq 0 ] && grep -qi "dnf" /tmp/hook_output.txt; then
    echo "Hook passthrough OK: dnf --version works"
else
    echo "FAIL: dnf --version failed through hook (exit=$DNF_EXIT)"
    cat /tmp/hook_output.txt
    rpm -e sonic-build-hooks > /dev/null 2>&1
    exit 1
fi

# Cleanup
rpm -e sonic-build-hooks > /dev/null 2>&1
rm -rf /tmp/test_cache

echo "PASS"
