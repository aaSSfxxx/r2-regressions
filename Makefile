T=	asm	\
	grep 	\
	math 	\
	redo 	\
	write	\
	undo

all: ${T}

${T}:
	@cd t ; ./$@

clean:
	rm -f t/out.* t/rad.*

.PHONY: all ${T} clean
