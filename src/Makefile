# Makefile
# Builds the SRE

# Assembly macros
asm=nasm
asm_flags=-f elf64 -g

# C macros
cc=gcc
cflags=-g

# C++ macros
cpp=g++
cpp_version=c++17
cppflags=-std=$(cpp_version) -g

# General makefile macros
target=sre.o

asm_obj=memory.o string.o
mam_obj=mam.o
sre_dependencies=sre.h runtime_error_codes.h $(asm_obj) $(mam_obj)

# The default build configuration
default: $(target)

# Whole build config
$(target): $(sre_dependencies)
	@echo "Building SRE..."
	$(cc) $(cflags) -o $@ -c sre.c
	@echo "Build successful."

mam.o: mam.h mam.cpp runtime_error_codes.h
	$(cpp) $(cppflags) -o mam.o -c mam.cpp

# Assembly
memory.o: asm/memory.s
	$(asm) $(asm_flags) asm/memory.s -o memory.o

string.o: asm/string.s
	$(asm) $(asm_flags) asm/string.s -o string.o

# Clean-up
clean:
	rm *.o

.PHONY: $(target) clean
