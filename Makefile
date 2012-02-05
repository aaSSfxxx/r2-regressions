T=	asm		\
	empty		\
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
	write		\
	write_cache

# failing tests
FT=	help_slash-cQ

all: ${T}
fail: ${FT}

${T}:
	@cd t ; ./$@

${FT}:
	@cd t ; ./$@

clean:
	rm -f t/out.* t/val.* t/rad.* t/exp.* t/radare2.core t/*.tmp

.PHONY: all ${T} clean
