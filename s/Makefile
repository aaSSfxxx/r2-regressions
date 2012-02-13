TARGETS = x86-simple x64-simple

all: $(TARGETS)

clean:
	rm -f $(TARGETS) *.o


x86%.o: x86%.s
	nasm -f elf32 $<

x64%.o: x64%.s
	nasm -f elf64 $<

x86%: x86%.o
	ld -m elf_i386 -s -o $@ $<

x64%: x64%.o
	ld -m elf_x86_64 -s -o $@ $<

.PHONY: all clean
