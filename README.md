# SRE

The SIN runtime environment, intended for use with the [SINx86 compiler project](https://github.com/rlannon/SINx86).

## Goal of the Project

The aforementioned compiler for SIN requires a fairly limited amount of runtime support to enable all of the language's features. This is the library that implements them.

## Overview of the SRE

The SIN Runtime Environment (SRE) is the runtime library that provides support for many features of the SIN programming language. The compiler heavily relies on the SRE to perform tasks related to memory management, specifically resource allocation and garbage collection; memory, array, and string copying; and various other utility functions.

This documentation is for the SRE only and assumes some level of knowledge with the SIN programming language and the compiler functionality. For more information on the SIN programming languages, see the [GitHub Pages site](rlannon.github.io/SIN).

## Getting Started

### Building the Library

This project is written in a mixture of C++, C, and x86. Certain features, like the Memory Allocation Manager, are written in C++ (partially out of laziness to avoid implementating a hash table), while some routines must be  I am targeting Linux for the time being, though the end goal is to have a cross-platform product. Currently, no working binaries are available, though a makefile is included for compilation; this requires [nasm](https://www.nasm.us/) to assemble the `.s` files and GCC (and G++ for the C++).

Note, however, that there is not currently a compiler version that would even make this project useful.

### Using the Library

This library must be statically linked with *all* SIN programs in order for them to run, as they rely on the functionality from this library. Again, as there is not currently a working compiler for the language, that doesn't really matter for the time being.
