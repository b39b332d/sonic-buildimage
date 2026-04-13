#!/bin/bash
# run_all_tests.sh - Run all tests inside the Docker container
# Usage: docker run --rm -v /tmp/sonic-build-hooks-rpm:/src sonic-build-hooks-test bash tests/run_all_tests.sh

set -e

echo "========================================"
echo " sonic-build-hooks RPM Test Suite"
echo "========================================"
echo ""

PASS=0
FAIL=0
TOTAL=0

run_test() {
    local name=$1
    local script=$2
    TOTAL=$((TOTAL + 1))
    echo "--- [${TOTAL}] $name ---"
    if bash tests/$script; then
        echo "    PASS"
        PASS=$((PASS + 1))
    else
        echo "    FAIL"
        FAIL=$((FAIL + 1))
    fi
    echo ""
}

# Run tests
run_test "1. RPM package build"          "test_rpm_build.sh"
run_test "2. RPM package install"        "test_rpm_install.sh"
run_test "3. collect_version_files"       "test_collect_version.sh"
run_test "4. buildinfo_base.sh"         "test_buildinfo_base.sh"
run_test "5. pre/post run_buildinfo"    "test_pre_post_buildinfo.sh"
run_test "6. dnf hook"                   "test_dnf_hook.sh"
run_test "7. symlink_build_hooks"       "test_symlink.sh"

echo "========================================"
echo " Results: $PASS/$TOTAL passed, $FAIL/$TOTAL failed"
echo "========================================"

if [ $FAIL -ne 0 ]; then
    exit 1
fi
