#!/bin/bash
# test_buildinfo_base.sh - Test buildinfo_base.sh loads without errors

set -e

cd /root/sonic-build-hooks
rpm -ivh buildinfo/sonic-build-hooks-1.0-1.noarch.rpm > /dev/null

# Setup minimal environment
export BUILDINFO_PATH=/usr/local/share/buildinfo
export VERSION_PATH=$BUILDINFO_PATH/versions
export LOG_PATH=$BUILDINFO_PATH/log
export PKG_CACHE_PATH=/tmp/test_cache
export IMAGENAME="test"

mkdir -p $VERSION_PATH $LOG_PATH $PKG_CACHE_PATH

# Create a minimal config
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

echo "Testing buildinfo_base.sh loading..."
if bash -c '. /usr/local/share/buildinfo/scripts/buildinfo_base.sh && echo "LOADED_OK"' | grep -q "LOADED_OK"; then
    echo "buildinfo_base.sh loaded successfully"
else
    echo "FAIL: buildinfo_base.sh failed to load"
    rpm -e sonic-build-hooks > /dev/null 2>&1
    exit 1
fi

# Test get_command
echo "Testing get_command..."
RESULT=$(bash -c '. /usr/local/share/buildinfo/scripts/buildinfo_base.sh; get_command bash')
if [ -z "$RESULT" ]; then
    echo "FAIL: get_command returned empty for bash"
    rpm -e sonic-build-hooks > /dev/null 2>&1
    exit 1
fi
echo "get_command bash = $RESULT"

# Test check_version_control
RESULT=$(bash -c '. /usr/local/share/buildinfo/scripts/buildinfo_base.sh; check_version_control rpm')
if [ "$RESULT" != "y" ]; then
    echo "FAIL: check_version_control rpm should return y"
    rpm -e sonic-build-hooks > /dev/null 2>&1
    exit 1
fi
echo "check_version_control rpm = $RESULT (OK)"

# Test non-matching component
RESULT=$(bash -c '. /usr/local/share/buildinfo/scripts/buildinfo_base.sh; check_version_control deb')
if [ "$RESULT" != "n" ]; then
    echo "FAIL: check_version_control deb should return n"
    rpm -e sonic-build-hooks > /dev/null 2>&1
    exit 1
fi
echo "check_version_control deb = $RESULT (OK)"

# Cleanup
rpm -e sonic-build-hooks > /dev/null 2>&1
rm -rf /tmp/test_cache

echo "PASS"
