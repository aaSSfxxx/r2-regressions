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

lock() {
	while ! ln -s . lock 2>/dev/null ; do :; done
}

unlock() {
	mv lock deleteme && rm -f deleteme
}

# Statistics.
TESTS_TOTAL=0
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

if [ "$1" = "-j" ]; then
	shift
	THREADS=$1
	shift
else
	THREADS=8
fi

. ./tests.sh

r2 > /dev/null
if [ $? != 0 ]; then
    echo "Cannot find r2"
    exit 1
fi

NTH=0
TFS=""

[ "${THREADS}" -lt 1 ] && THREADS=1
[ -z "${THREADS}" ] && THREADS=8

echo "==> Using $THREADS threads"

FILE_SUCCESS=$(mktemp /tmp/.r2-stats.XXXXXX)
FILE_FAILED=$(mktemp /tmp/.r2-stats.XXXXXX)
FILE_FIXED=$(mktemp /tmp/.r2-stats.XXXXXX)
FILE_BROKEN=$(mktemp /tmp/.r2-stats.XXXXXX)
FILE_TOTAL=$(mktemp /tmp/.r2-stats.XXXXXX)
FILES="${FILE_SUCCESS} ${FILE_FAILED} ${FILE_FIXED} ${FILE_BROKEN} ${FILE_TOTAL}"

for a in $FILES ; do
  echo 0 > $a
done

runfile() {
  [ -z "$2" ] && return
  if [ $THREADS -gt 1 ]; then
    TF=`mktemp /tmp/.r2-tests.XXXXXX`
    TFS="${TFS} $TF"
    NTH=$(($NTH+1))
    (
      cd $1 
      . ./$2 > $TF
      lock
      N=$((`cat ${FILE_SUCCESS}`+${TESTS_SUCCESS})); echo $N > ${FILE_SUCCESS}
      N=$((`cat ${FILE_FAILED}`+${TESTS_FAILED})); echo $N > ${FILE_FAILED}
      N=$((`cat ${FILE_FIXED}`+${TESTS_FIXED})); echo $N > ${FILE_FIXED}
      N=$((`cat ${FILE_BROKEN}`+${TESTS_BROKEN})); echo $N > ${FILE_BROKEN}
      N=$((`cat ${FILE_TOTAL}`+${TESTS_TOTAL})); echo $N > ${FILE_TOTAL}
      unlock
    ) &
    if [ ${NTH} -ge $THREADS ]; then
      NTH=0
      wait
      cat $TFS
      TFS=""
    fi
# XXX counters fail here
  else
  (
    cd $1
    . ./$2
  )
  fi
}

R=$PWD
# Run all tests.
T="t"; [ -n "$1" ] && T="$1"
[ -f "$T" -a -x "$T" ] && exec $T
cd $T || die "t/ doesn't exist"
for file in * ; do
   [ "$file" = '*' ] && break
   if [ -d "$file" ]; then
      for file2 in $(ls $file); do
         TEST_NAME=$(echo "${file2}" | sed 's/.sh$//')
	 NAME=`cd $file ; basename $file2`
         #TEST_NAME=$file
	 runfile ./$file/ ${file2}
      done
   else
      NAME=`basename $file`
      TEST_NAME=$NAME
      runfile ./ ${file}
   fi
done
rm -f $TFS

wait
if [ $THREADS -gt 1 ]; then
    TESTS_SUCCESS=$(cat ${FILE_SUCCESS})
    TESTS_FAILED=$(cat ${FILE_FAILED})
    TESTS_FIXED=$(cat ${FILE_FIXED})
    TESTS_BROKEN=$(cat ${FILE_BROKEN})
    TESTS_TOTAL=$(cat ${FILE_TOTAL})
fi
rm -f ${FILES}

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
    print_broken "${TESTS_BROKEN}"
else
    print_broken 0
fi
printf "      FAILED"
if [ "${TESTS_FAILED}" -gt 0 ]; then
    print_failed  "${TESTS_FAILED}"
else
    print_failed  0
fi
printf "      TOTAL\r"
print_label "[${TESTS_TOTAL}]"
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
if [ "${TESTS_TOTAL}" -eq "${TESTS_SUCCESS}" ]; then
    exit 0
elif [ "${TESTS_FAILED}" -eq 0 ]; then
    if [ "${TESTS_BROKEN}" -ge 0 ]; then
        exit 2
    elif [ "${TESTS_FIXED}" -ge 0 ]; then
        exit 3
    fi
fi
exit 1
