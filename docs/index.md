# SIN Runtime Environment

## Documentation

These pages provide the usage documentation for the SIN Runtime Environment, an integral part of the [SIN compiler project](https://rlannon.github.io/SINx86). The environment is to be implemented in a mixture of C++, C, and x86. The x86 routines are partly necessary to serve as wrapper functions between the different calling conventions, but also implement some functionality that would be difficult in C due to type differences between the languages (particularly when it comes to strings and arrays).

Note the [Memory Allocation Manager](https://rlannon.github.io/SINx86/Memory%20Allocation%20Manager) is implemented in C++ here (admittedly, partially out of laziness -- so as to avoid implementing a hash table); `std::unordered_map` is used instead. C wrapper functions are provided so the MAM can be used with the SRE C functions.
