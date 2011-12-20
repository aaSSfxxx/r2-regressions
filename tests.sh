# do not execute #
. ../config.sh

out=`mktemp out.XXXXXX`
rad=`mktemp rad.XXXXXX`
exp=`mktemp exp.XXXXXX`

run_test() {
	cmd="${DBG} ${r2} -e scr.color=0 -n -q -i ${rad} ${ARGS} ${FILE} ${PIP}"
	echo "TEST: `basename ${NAME}`"
	echo "Running: ${cmd}"

	echo "${CMDS}" > ${rad}
	echo "${EXPECT}" > ${exp}

	eval ${cmd}
	if [ ! $? = 0 ]; then
		printf "\x1b[31m"
		echo "Running ${NAME} ... FAIL (radare2 crashed?)"
		printf "\x1b[0m"
	elif [ "`cat $out`" = "${EXPECT}" ]; then
		printf "\x1b[32m"
		echo "Running ${NAME} ... SUCCESS"
		printf "\x1b[0m"
	else
		printf "\x1b[31m"
		echo "Running ${NAME} ... FAIL (unexpected outcome)"
		printf "\x1b[0m"
		diff -u ${exp} ${out}
	fi
	rm -f ${out} ${rad} ${exp}
	echo "-------------------------------------------------------------------"
}

PIP=">${out}"
case "${DEBUG}" in
0|no)
	DBG="cat ${rad} |"
	DBG="echo q |"
	;;
1|yes|gdb)
	DBG="gdb --args"
	PIP=""
	;;
2|valgrind)
	DBG="valgrind --leak-check=full --track-origins=yes"
	DBG="${DBG} --workaround-gcc296-bugs=yes --read-var-info=yes"
	PIP="2>&1 | tee out.valgrind"
	;;
esac

NAME=$0
export DBG CMDS NAME ARGS FILE EXPECT PIP
run_test
