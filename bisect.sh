#!/bin/sh
if [ -z "$1" ]; then
	echo "Use ./bisect.sh [test]"
	echo "    ./bisect.sh -a      # test all"
	echo "    ./bisect.sh -b      # test all BROKEN"
	exit 1
fi
TESTS=$@
UPTO=32
if [ "${TESTS}" = "-a" ]; then
	TESTS=$(cd t ; ls)
echo pene
elif [ "${TESTS}" = "-b" ]; then
	TESTS=$(cd t ; grep BROKEN=1 *|cut -d : -f 1)
fi
if [ -z "${TESTS}" ]; then
	echo "* No matching test"
	exit 1
fi
for a in ${TESTS}; do
	if [ ! -x t/$a ]; then
		echo "* Cannot find test $a"
		exit 1
	fi
done
cd ..
echo "* Running bisect on ${TESTS}"
REVS=$(hg log|grep ^changeset|awk -F : '{print $2}')
for a in ${REVS}; do
	[ "${UPTO}" = 0 ] && break
	UPTO=$(($UPTO-1))
	echo "* Building revision $a ..."
	sleep 2
	sys/install-rev.sh ${a} > build.$a.log 2>&1
	cd r2-regressions/t
	for b in ${TESTS}; do
		R2_SOURCED=1 ./$b
		if [ $? = 0 ]; then
			echo "* Worked on revision $a"
			exit 0
		else
			echo "* Error on revision $a"
		fi
	done
	cd ../..
done
exit 1
