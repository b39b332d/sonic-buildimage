#!/bin/bash
# test_pre_post_buildinfo.sh - Test pre/post run hooks work end-to-end

set -e

cd /root/sonic-build-hooks
rpm -ivh buildinfo/sonic-build-hooks-1.0-1.noarch.rpm > /dev/null

# Setup environment
export IMAGENAME="test-docker"
export BUILDINFO_PATH=/usr/local/share/buildinfo
export VERSION_PATH=$BUILDINFO_PATH/versions
export PRE_VERSION_PATH=$BUILDINFO_PATH/pre-versions
export POST_VERSION_PATH=$BUILDINFO_PATH/post-versions
export BUILD_VERSION_PATH=$BUILDINFO_PATH/build-versions
export LOG_PATH=$BUILDINFO_PATH/log
export PKG_CACHE_PATH=/tmp/test_vcache/test-docker
export SONIC_VERSION_CONTROL_COMPONENTS=rpm,py3
export ENABLE_VERSION_CONTROL_RPM=y
export ENABLE_VERSION_CONTROL_PY3=y
export ENABLE_VERSION_CONTROL_WEB=n
export SONIC_VERSION_CACHE=
export PACKAGE_URL_PREFIX=
export DISTRO=openeuler
export PIP_HTTP_TIMEOUT=120

mkdir -p $PRE_VERSION_PATH $POST_VERSION_PATH $BUILD_VERSION_PATH $LOG_PATH $PKG_CACHE_PATH
mkdir -p $BUILDINFO_PATH/config

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

# Install some test packages so we have something to collect
dnf install -y coreutils 2>/dev/null || true

# Run pre_run_buildinfo
echo "Running pre_run_buildinfo..."
bash /usr/local/share/buildinfo/scripts/pre_run_buildinfo test-docker 2>&1
echo "pre_run_buildinfo exit code: $?"

# Verify pre-versions were collected
if [ ! -d "$PRE_VERSION_PATH" ] || [ -z "$(ls $PRE_VERSION_PATH/ 2>/dev/null)" ]; then
    echo "FAIL: pre-versions directory is empty after pre_run_buildinfo"
    rpm -e sonic-build-hooks > /dev/null 2>&1
    exit 1
fi
PRE_FILES=$(ls $PRE_VERSION_PATH/ 2>/dev/null | wc -l)
echo "Pre-versions collected: $PRE_FILES files"

# Run post_run_buildinfo
echo "Running post_run_buildinfo..."
bash /usr/local/share/buildinfo/scripts/post_run_buildinfo test-docker 2>&1
echo "post_run_buildinfo exit code: $?"

# Verify post-versions were collected
if [ ! -d "$POST_VERSION_PATH" ] || [ -z "$(ls $POST_VERSION_PATH/ 2>/dev/null)" ]; then
    echo "FAIL: post-versions directory is empty after post_run_buildinfo"
    rpm -e sonic-build-hooks > /dev/null 2>&1
    exit 1
fi
POST_FILES=$(ls $POST_VERSION_PATH/ 2>/dev/null | wc -l)
echo "Post-versions collected: $POST_FILES files"

# Verify symlinks were created by symlink_build_hooks
bash /usr/local/share/buildinfo/scripts/symlink_build_hooks
if [ -L /usr/local/sbin/dnf ]; then
    echo "dnf hook symlink OK: /usr/local/sbin/dnf -> $(readlink /usr/local/sbin/dnf)"
else
    echo "FAIL: /usr/local/sbin/dnf symlink not created"
    rpm -e sonic-build-hooks > /dev/null 2>&1
    exit 1
fi

# Cleanup
rpm -e sonic-build-hooks > /dev/null 2>&1
rm -rf /tmp/test_vcache

echo "PASS"
