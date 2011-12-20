T=	asm		\
	filesize	\
	grep 		\
	math 		\
	noargs_f	\
	redo 		\
	seek		\
	write		\
	undo 

# Failing tests, pending fixes upstream in r2 hg
FT=	flag_add	\
	noargs_Qv	\
	search_ascii	\
	woa


all: ${T}
fail: ${FT}

${T}:
	@cd t ; ./$@

${FT}:
	@cd t ; ./$@

clean:
	rm -f t/out.* t/rad.* t/exp.* t/radare2.core

.PHONY: all ${T} clean
