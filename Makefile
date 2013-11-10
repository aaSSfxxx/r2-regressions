PULLADDR=https://github.com/radare/r2-regressions.git

all:
	-git pull ${PULLADDR}
	@sh run_tests.sh

broken:
	@cd t ; grep BROKEN=1 * | cut -d : -f1 |sort -u

clean:
	rm -rf tmp

.PHONY: all clean
