#!/do/not/execute

run_test() {
    if [ -z "${R2}" ]; then
        R2=$(which radare2)
    fi

    # Set by run_tests.sh if all tests are run - otherwise get it from test
    # name.
    if [ -z "${TEST_NAME}" ]; then
        TEST_NAME=$(basename "$0" | sed 's/\.sh$//')
    fi

    NAME_TMP="${TEST_NAME}"
    [ -n "${NAME}" ]     && NAME_TMP="${NAME_TMP}: ${NAME}"
    [ -n "${VALGRIND}" ] && NAME_TMP="${NAME_TMP} (valgrind)"
    printf "%-40s" "${NAME_TMP}"

    # Check required variables.
    if [ -z "${FILE}" ]; then
        test_failed "FILE missing!"
        test_reset
        return
    fi
    if [ -z "${CMDS}" ]; then
        test_failed "CMDS missing!"
        test_reset
        return
    fi
    # ${EXPECT} can be empty. Don't check it.

    # Verbose mode is always used if only a single test is run.
    if [ -z "${R2_SOURCED}" ]; then
        VERBOSE=1
    fi

    mkdir -p ../tmp
    TMP_RAD=$(mktemp "../tmp/${TEST_NAME}-rad.XXXXXX")
    TMP_OUT=$(mktemp "../tmp/${TEST_NAME}-out.XXXXXX")
    TMP_VAL=$(mktemp "../tmp/${TEST_NAME}-val.XXXXXX")
    TMP_EXP=$(mktemp "../tmp/${TEST_NAME}-exp.XXXXXX")

    # No colors and no user configs.
    R2ARGS="${R2} -e scr.color=0 -N -q -i ${TMP_RAD} ${ARGS} ${FILE}"
    R2CMD=
    # ${FILTER} can be used to filter out random results to create stable
    # tests.
    if [ -n "${FILTER}" ]; then
        R2ARGS="${R2ARGS} 2>&1 | ${FILTER} > ${TMP_OUT}"
    else
        R2ARGS="${R2ARGS} > ${TMP_OUT} 2>&1"
    fi
    # Valgrind to detect memory corruption.
    if [ -n "${VALGRIND}" ]; then
        R2CMD="valgrind --error-exitcode=47 --log-file=${TMP_VAL}"
    fi
    R2CMD="echo q | ${R2CMD} ${R2ARGS}"

    # Put expected outcome and program to run in files and run the test.
    echo "${CMDS}"   > ${TMP_RAD}
    echo "${EXPECT}" > ${TMP_EXP}
    if [ -n "${VERBOSE}" ]; then
        echo "${R2CMD}"
    fi
    eval "${R2CMD}"
    CODE=$?

    if [ -n "${R2_SOURCED}" ]; then
        TESTS_RUN=$(( TESTS_RUN + 1 ))
    fi

    if [ ${CODE} -eq 47 ]; then
        test_failed "valgrind error"
        if [ -n "${VERBOSE}" ]; then
            cat "${TMP_VAL}"
            echo
        fi

    elif [ ! ${CODE} -eq 0 ]; then
        test_failed "radare2 crashed"
        if [ -n "${VERBOSE}" ]; then
            cat "${TMP_OUT}"
            echo
        fi

    elif [ "$(cat "${TMP_OUT}")" = "${EXPECT}" ]; then
        test_success

    else
        test_failed "unexpected outcome"
        if [ -n "${VERBOSE}" ]; then
            diff -u ${TMP_EXP} ${TMP_OUT}
            echo
        fi
    fi

    rm -f "${TMP_RAD}" "${TMP_OUT}" "${TMP_VAL}" "${TMP_EXP}"

    # Reset most variables in case the next test script doesn't set them.
    test_reset
}

test_reset() {
    NAME=
    FILE=
    ARGS=
    CMDS=
    EXPECT=
    FILTER=
    BROKEN=
}

test_success() {
    if [ -z "${BROKEN}" ]; then
        print_success "OK "
    else
        print_fixed "FIXED"
    fi

    if [ -n "${R2_SOURCED}" ]; then
        if [ -z "${BROKEN}" ]; then
            TESTS_SUCCESS=$(( TESTS_SUCCESS + 1 ))
        else
            TESTS_FIXED=$(( TESTS_FIXED + 1 ))
        fi
    fi
}
test_failed() {
    if [ -z "${BROKEN}" ]; then
        print_failed "FAIL ($1)"
    else
        print_failed "BROKEN ($1)"
    fi

    if [ -n "${R2_SOURCED}" ]; then
        if [ -z "${BROKEN}" ]; then
            TESTS_FAILED=$(( TESTS_FAILED + 1 ))
        else
            TESTS_BROKEN=$(( TESTS_BROKEN + 1 ))
        fi
    fi
}

print_success() {
    printf "%b" "\033[32m${*}\033[0m\n"
}
print_failed() {
    printf "%b" "\033[31m${*}\033[0m\n"
}
print_fixed() {
    printf "%b" "\033[33m${*}\033[0m\n"
}
