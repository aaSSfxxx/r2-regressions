T=	asm		\
	filesize	\
	flag_add	\
	grep 		\
	math 		\
	noargs_Qv	\
	noargs_f	\
	redo 		\
	search_ascii	\
	seek		\
	undo		\
	woa		\
	write

# failing tests
FT=	write_cache

all: ${T}
fail: ${FT}

${T}:
	@cd t ; ./$@

${FT}:
	@cd t ; ./$@

clean:
	rm -f t/out.* t/val.* t/rad.* t/exp.* t/radare2.core

.PHONY: all ${T} clean
