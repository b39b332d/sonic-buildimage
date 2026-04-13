#!/bin/bash
# test_rpm_install.sh - Test RPM package can be installed and uninstalled
set -e

cd /root/sonic-build-hooks
RPM_FILE="buildinfo/sonic-build-hooks-1.0-1.noarch.rpm"

echo "Installing RPM..."
rpm -ivh "$RPM_FILE"

echo "Verifying installation..."

# Check files exist
[ -f /usr/local/share/buildinfo/scripts/buildinfo_base.sh ] || { echo "FAIL: buildinfo_base.sh not installed"; exit 1; }
[ -f /usr/local/share/buildinfo/scripts/collect_version_files ] || { echo "FAIL: collect_version_files not installed"; exit 1; }
[ -f /usr/local/share/buildinfo/scripts/pre_run_buildinfo ] || { echo "FAIL: pre_runinfo not installed"; exit 1; }
[ -f /usr/local/share/buildinfo/scripts/post_run_buildinfo ] || { echo "FAIL: post_runinfo not installed"; exit 1; }
[ -f /usr/local/share/buildinfo/scripts/post_run_cleanup ] || { echo "FAIL: post_run_cleanup not installed"; exit 1; }
[ -f /usr/local/share/buildinfo/scripts/symlink_build_hooks ] || { echo "FAIL: symlink_build_hooks not installed"; exit 1; }
[ -f /usr/local/share/buildinfo/scripts/utils.sh ] || { echo "FAIL: utils.sh not installed"; exit 1; }
[ -f /usr/local/share/buildinfo/hooks/dnf ] || { echo "FAIL: hooks/dnf not installed"; exit 1; }
[ -f /usr/local/share/buildinfo/hooks/rpm ] || { echo "FAIL: hooks/rpm not installed"; exit 1; }
[ -f /usr/local/share/buildinfo/hooks/pip3 ] || { echo "FAIL: hooks/pip3 not installed"; exit 1; }

# Check symlinks
[ -L /usr/sbin/symlink_build_hooks ] || { echo "FAIL: symlink_build_hooks symlink missing"; exit 1; }
[ -L /usr/sbin/pre_run_buildinfo ] || { echo "FAIL: pre_run_buildinfo symlink missing"; exit 1; }
[ -L /usr/sbin/collect_version_files ] || { echo "FAIL: collect_version_files symlink missing"; exit 1; }

echo "Files verified OK"
echo "Uninstalling RPM..."
rpm -e sonic-build-hooks

echo "PASS"
