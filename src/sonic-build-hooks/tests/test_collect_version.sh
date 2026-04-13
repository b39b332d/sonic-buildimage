#!/bin/bash
# test_collect_version_files.sh - Test version collection works with RPM

set -e

# Install the package first
cd /root/sonic-build-hooks
rpm -ivh buildinfo/sonic-build-hooks-1.0-1.noarch.rpm > /dev/null

# Setup minimal buildinfo environment (as pre_run_buildinfo would do)
export IMAGENAME="test-image"
export BUILDINFO_PATH=/usr/local/share/buildinfo
export VERSION_PATH=$BUILDINFO_PATH/versions
export PRE_VERSION_PATH=$BUILDINFO_PATH/pre-versions
export POST_VERSION_PATH=$BUILDINFO_PATH/post-versions
export BUILD_VERSION_PATH=$BUILDINFO_PATH/build-versions
export LOG_PATH=$BUILDINFO_PATH/log
export PKG_CACHE_PATH=/tmp/test_vcache/test-image

mkdir -p $PRE_VERSION_PATH $POST_VERSION_PATH $BUILD_VERSION_PATH $LOG_PATH $PKG_CACHE_PATH

# Run collect_version_files
echo "Running collect_version_files..."
bash /usr/local/share/buildinfo/scripts/collect_version_files /tmp/test_output

echo "Checking output..."
if [ ! -d /tmp/test_output ]; then
    echo "FAIL: output directory not created"
    rpm -e sonic-build-hooks > /dev/null 2>&1
    exit 1
fi

# Check RPM versions file exists and has content
RPM_VER=$(find /tmp/test_output -name "versions-rpm-*" | head -1)
if [ -z "$RPM_VER" ]; then
    echo "FAIL: versions-rpm file not found"
    rpm -e sonic-buildhooks > /dev/null 2>&1
    exit 1
fi

LINE_COUNT=$(wc -l < "$RPM_VER")
if [ "$LINE_COUNT" -lt 5 ]; then
    echo "FAIL: versions-rpm has too few entries ($LINE_COUNT lines)"
    rpm -e sonic-build-hooks > /dev/null 2>&1
    exit 1
fi

echo "Collected $LINE_COUNT RPM package versions"

# Check format (package==version-release)
if head -3 "$RPM_VER" | grep -qE '^[a-zA-Z].*=='; then
    echo "Format looks correct (NAME==VERSION-RELEASE)"
else
    echo "FAIL: unexpected format in versions-rpm"
    head -3 "$RPM_VER"
    rpm -e sonic-build-hooks > /dev/null 2>&1
    exit 1
fi

# Cleanup
rpm -e sonic-build-hooks > /dev/null 2>&1
rm -rf /tmp/test_output /tmp/test_vcache

echo "PASS"
