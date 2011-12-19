T=	asm		\
	filesize	\
	grep 		\
	math 		\
	redo 		\
	seek		\
	write		\
	undo
#	noargs
#	search_ascii

all: ${T}

${T}:
	@cd t ; ./$@

clean:
	rm -f t/out.* t/rad.*

.PHONY: all ${T} clean
