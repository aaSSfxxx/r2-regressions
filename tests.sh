#!/do/not/execute

run_test() {

	cmd="echo q | ${r2} -e scr.color=0 -n -q -i ${rad} ${ARGS} ${FILE} > ${out}"

	echo "Next Test: `basename ${NAME}`"
	echo "Running: ${cmd}"

	# put expected outcome and program to run in files
	echo "${CMDS}" > ${rad}
	echo "${EXPECT}" > ${exp}

	eval ${cmd}
	if [ ! $? = 0 ]; then
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
	rm -f ${out} ${rad} ${exp}
	echo "-------------------------------------------------------------------"
}

r2=${R2}
if [ -z "${R2}" ]; then
	r2=`which radare2`
fi

out=`mktemp out.XXXXXX`
rad=`mktemp rad.XXXXXX`
exp=`mktemp exp.XXXXXX`

NAME=$0

run_test
