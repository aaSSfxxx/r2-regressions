#!/do/not/execute

run_test() {
	r2args="${r2} -e scr.color=0 -n -q -i ${rad} ${ARGS} ${FILE}"

	# ${FILTER} can be used to filter out random results to create stable
	# tests.
	if [ -n "${FILTER}" ]; then
		r2args="${r2args} 2>&1 | ${FILTER} > ${out}"
	else
		r2args="${r2args} > ${out} 2>&1"
	fi

	if [ -n "${VALGRIND}" ]; then
		cmd="valgrind --error-exitcode=47 --log-file=${val} ${r2args}"
	else
		cmd="${r2args}"
	fi
	cmd="echo q | ${cmd}"

	echo "Next Test: `basename ${NAME}`"
	echo "Running: ${cmd}"

	# put expected outcome and program to run in files
	echo "${CMDS}" > ${rad}
	echo "${EXPECT}" > ${exp}

	eval ${cmd}
	code=$?
	if [ ${code} -eq 47 ]; then
		printf "\x1b[31m"
		echo "FAIL (Valgrind error)"
		printf "\x1b[0m"
		cat ${val}
	elif [ ! ${code} -eq 0 ]; then
		printf "\x1b[31m"
		echo "FAIL (Radare2 crashed?)"
		printf "\x1b[0m"
	elif [ "`cat $out`" = "${EXPECT}" ]; then
		printf "\x1b[32m"
		echo "SUCCESS"
		printf "\x1b[0m"
	else
		printf "\x1b[31m"
		echo "FAIL (Unexpected outcome)"
		printf "\x1b[0m"
		diff -u ${exp} ${out}
	fi
	rm -f ${out} ${val} ${rad} ${exp}
	echo "-------------------------------------------------------------------"
}

r2=${R2}
if [ -z "${R2}" ]; then
	r2=`which radare2`
fi

out=`mktemp out.XXXXXX`
val=`mktemp val.XXXXXX`
rad=`mktemp rad.XXXXXX`
exp=`mktemp exp.XXXXXX`

NAME=$0

run_test
