#!/bin/sh
#
# Copyright (C) 2011-2013  pancake <pancake@nopcode.org>
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

r2 > /dev/null
if [ $? != 0 ]; then
    echo "Cannot find r2"
    exit 1
fi


R=$PWD
# Run all tests.
T="t"; [ -n "$1" ] && T="$1"
[ -f "$T" -a -x "$T" ] && exec $T
cd $T || die "t/ doesn't exist"
for file in * ; do
   [ "$file" = '*' ] && break
   if [ -d "$file" ]; then
      cd $file
      for file2 in *; do
         [ "$file2" = '*' ] && break
         TEST_NAME=$(echo "${file2}" | sed 's/.sh$//')
	 NAME=`basename $file2`
         TEST_NAME=$file
         . ./${file2}
      done
      cd ..
   else
      NAME=`basename $file`
      TEST_NAME=$NAME
      . ./${file}
   fi
done

# Print report.
echo
echo "=== Report ==="
echo
printf "      SUCCESS"
if [ "${TESTS_SUCCESS}" -gt 0 ]; then
    print_success "${TESTS_SUCCESS}"
else
    print_failed "${TESTS_SUCCESS}"
fi
printf "      FIXED"
if [ "${TESTS_FIXED}" -gt 0 ]; then
    print_fixed   "${TESTS_FIXED}"
else
    print_fixed   0
fi
printf "      BROKEN"
if [ "${TESTS_BROKEN}" -gt 0 ]; then
    print_failed  "${TESTS_BROKEN}"
else
    print_failed  0
fi
printf "      FAILED"
if [ "${TESTS_FAILED}" -gt 0 ]; then
    print_failed  "${TESTS_FAILED}"
else
    print_failed  0
fi
printf "      TOTAL\r"
print_label "[${TESTS_RUN}]"
echo

# Save statistics
cd $R
V=`r2 -v 2>/dev/null| grep ^rada| awk '{print $5}'`
touch stats.csv
grep -v "^$V" stats.csv > .stats.csv
echo "$V,${TESTS_SUCCESS},${TESTS_FIXED},${TESTS_BROKEN},${TESTS_FAILED},${FAILED}" >> .stats.csv
sort .stats.csv > stats.csv
rm -f .stats.csv

if [ "${TESTS_FAILED}" -gt 0 ]; then
  exit 1
fi
exit 0

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
