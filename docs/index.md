# SIN Runtime Environment

## Documentation

These pages provide the usage documentation for the SIN Runtime Environment, an integral part of the [SIN compiler project](https://rlannon.github.io/SINx86). The environment is to be implemented mostly in C (allowing for easier cross-compatibility), but will require *some* x86 routines to serve as wrappers for the C functions as well as to implement certain string and array functionality due to differences in the implementations of these types between SIN and C.

Note the [Memory Allocation Manager](https://rlannon.github.io/SINx86/Memory%20Allocation%20Manager) is implemented in C++ here so as to avoid implementing a hash table (and reinventing the wheel); `std::unordered_map` is used instead. C wrapper functions are provided so the MAM can be used with the SRE C functions.
