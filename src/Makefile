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
target=test

asm_obj=memory.o string.o
mam_obj=mam.o
sre_dependencies=sre.h runtime_error_codes.h $(asm_obj) $(mam_obj)
test_dependencies=sre.o $(sre_dependencies)

# The default build configuration
default: $(target)

# Whole build config
$(target): $(test_dependencies)
	@echo "Building SRE..."
	$(cpp) $(cppflags) -o $@ main.cpp $^
	@echo "Build successful."

sre.o: $(sre_dependencies)
	$(cc) $(cflags) -o sre.o -c sre.c

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
