all:
	@sh run_tests.sh

clean:
	rm -rf tmp

.PHONY: all clean
