#!/bin/bash
# test_rpm_build.sh - Test RPM package can be built
set -e

cd /root/sonic-build-hooks

# Clean previous build
rm -rf buildinfo rpmbuild 2>/dev/null || true

# Build RPM directly using rpmbuild
echo "Building RPM package..."
mkdir -p rpmbuild/{SOURCES,SPECS,RPMS,SRPMS,BUILDROOT}
cp -r scripts rpmbuild/SOURCES/
cp -r hooks rpmbuild/SOURCES/
cp sonic-build-hooks.spec rpmbuild/SPECS/
rpmbuild --define "_topdir $(pwd)/rpmbuild" -bb rpmbuild/SPECS/sonic-build-hooks.spec

# Copy result
mkdir -p buildinfo
cp rpmbuild/RPMS/noarch/sonic-build-hooks-1.0-1.noarch.rpm buildinfo/

# Verify output exists
RPM_FILE="buildinfo/sonic-build-hooks-1.0-1.noarch.rpm"
if [ ! -f "$RPM_FILE" ]; then
    echo "FAIL: RPM file not found at $RPM_FILE"
    exit 1
fi

# Verify it's a valid RPM
echo "Verifying RPM integrity..."
rpm -qpi "$RPM_FILE" > /dev/null

echo "RPM package built successfully: $(basename $RPM_FILE)"
echo "PASS"
