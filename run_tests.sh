#!/bin/sh

# Copyright (C) 2011       pancake<nopcode.org>
# Copyright (C) 2011-2012  Edd Barrett <vext01@gmail.com>
# Copyright (C) 2012       Simon Ruderich <simon@ruderich.org>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


# Statistics.
TESTS_RUN=0
TESTS_SUCCESS=0
TESTS_FAILED=0
TESTS_BROKEN=0
TESTS_FIXED=0

# Let tests.sh know the complete test suite is run, enables statistics.
R2_SOURCED=1

die() {
    echo "$1"
    exit 1
}

control_c() {
	echo
	exit 1
}
trap control_c 2

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
if [ "${TESTS_RUN}" -eq "${TESTS_SUCCESS}" ]; then
    exit 0
elif [ "${TESTS_FAILED}" -eq 0 ]; then
    if [ "${TESTS_BROKEN}" -ge 0 ]; then
        exit 2
    elif [ "${TESTS_FIXED}" -ge 0 ]; then
        exit 3
    fi
fi
exit 1
