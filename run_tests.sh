#!/bin/sh


die() {
    echo "$1"
    exit 1
}


# Statistics.
TESTS_RUN=0
TESTS_SUCCESS=0
TESTS_FAILED=0
TESTS_BROKEN=0
TESTS_FIXED=0

# Let tests.sh know the complete test suite is run, enables statistics.
R2_SOURCED=1

. ./tests.sh


# Run all tests.
cd t || die "t/ doesn't exist"
for file in *; do
    TEST_NAME=$(echo "${file}" | sed 's/.sh$//')
    . "./${file}"
done

# Print report.
echo
echo "RUN:     ${TESTS_RUN}"
printf "SUCCESS: ";
if [ "${TESTS_SUCCESS}" -gt 0 ]; then
    print_success "$TESTS_SUCCESS"
else
    print_failed "${TESTS_SUCCESS}"
fi
printf "FAILED:  ";
if [ "${TESTS_FAILED}" -gt 0 ]; then
    print_failed  "$TESTS_FAILED"
else
    echo 0
fi
printf "BROKEN:  ";
if [ "${TESTS_BROKEN}" -gt 0 ]; then
    print_failed  "$TESTS_BROKEN"
else
    echo 0
fi
printf "FIXED:   ";
if [ "${TESTS_FIXED}" -gt 0 ]; then
    print_fixed   "${TESTS_FIXED}"
else
    echo 0
fi

# Proper exit code.
if [ "$TESTS_RUN" -eq "$TESTS_SUCCESS" ]; then
    exit 0
elif [ "$TESTS_FIXED" -gt 0 ]; then
    exit 2
else
    exit 1
fi
