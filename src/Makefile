# Makefile
# Builds the SRE

# Get the name of the OS so we can ensure we build properly
os_name := $(shell uname)

# Assembly macros
asm=nasm
asm_flags=-g
ifeq ($(os_name), Linux)
	asm_flags += -f elf64
endif
ifeq ($(os_name), Darwin)
	asm_flags += -f macho64
endif
# todo: more checks to make this OS-agnostic

# C macros
cc=gcc
cflags=-g -Wall -fPIC

# C++ macros
cpp=g++
cpp_version=c++14
cppflags=-std=$(cpp_version) -g -Wall -fPIC

# General makefile macros
target=sre.o

asm_obj=array.o string.o
mam_obj=mam.o
sre_dependencies=sre.h runtime_error_codes.h $(asm_obj) $(mam_obj)

# The default build configuration
default: $(target)

# Whole build config
$(target): $(sre_dependencies)
	@echo "Building SRE..."
	$(cc) $(cflags) -c -o $@ sre.c
	@echo "Compiled successfully."
	@echo "Creating shared library..."
	ar rcs libSRE.a $@ $(mam_obj) $(asm_obj)
	rm *.o
	@echo "Done."

# todo: put sre.c in separate object here, like mam, array, and string? or keep in whole build?

# MAM
mam.o: mam.h mam.cpp runtime_error_codes.h
	$(cpp) $(cppflags) -o mam.o -c mam.cpp

# Assembly
array.o: asm/array.s
	$(asm) $(asm_flags) asm/array.s -o array.o

string.o: asm/string.s
	$(asm) $(asm_flags) asm/string.s -o string.o

# Clean-up
clean:
	rm *.o

.PHONY: $(target) clean
