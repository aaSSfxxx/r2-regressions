T=	asm		\
	filesize	\
	flag_add	\
	grep 		\
	math 		\
	noargs_Qv	\
	noargs_f	\
	redo 		\
	seek		\
	undo		\
	woa		\
	write		

# Failing tests, pending fixes upstream in r2 hg
FT=	search_ascii


all: ${T}
fail: ${FT}

${T}:
	@cd t ; ./$@

${FT}:
	@cd t ; ./$@

clean:
	rm -f t/out.* t/rad.* t/exp.* t/radare2.core

.PHONY: all ${T} clean
