# SRE

The SIN runtime environment, intended for use with the [SINx86 compiler project](https://github.com/rlannon/SINx86).

## Goal of the Project

The aforementioned compiler for the SIN programming language (a custom procedural language) requires a fairly limited runtime library to enable all of the language's (safety) features. This is the library that implements them.

## Overview of the SRE

The SIN Runtime Environment (SRE) is the runtime library that provides support for many features of the SIN programming language. The compiler heavily relies on the SRE to perform tasks related to memory management, specifically resource allocation and release as well as memory copies and various other utility functions.

This documentation is for the SRE only and assumes some level of knowledge with the SIN programming language and the compiler functionality. For more information on the SIN programming languages, see the [GitHub Pages site](rlannon.github.io/SIN).

## Getting Started

### Building the Library

This project is written mostly in C, with some x86 routines where necessary. I am targeting Linux for the time being, though the end goal is to have a cross-platform product. Currently, no working binaries are available, and must be compiled by hand. However, there is not currently a compiler version that would even make this project usable, so it doesn't matter anyway.

### Using the Library

This library must be linked with *all* SIN programs in order for them to run, as they rely on the functionality from this library. Again, as there is not currently a working compiler for the language, that doesn't really matter for the time being.
