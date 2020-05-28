# SRE Documentation

## Runtime Errors

There are a variety of runtime errors that can happen in software development in any language, and SIN is no exception. Although SIN does not support runtime exceptions in the same way as OOP languages like Python, it does support a form of (a bit more rudimentary) error handling similar to what exists in C. This error handling scheme utilizes error flags, and the onus is on the programmer to design code that can handle forseeable runtime errors. Some of these exceptions are non-recoverable, such as access violations and allocation errors.

### Error Codes

The following is the list of error codes that may be returned by the runtime environment.

#### General runtime errors

| Code | Name | Description | Recoverable? |
| `0xB0` | `SRE_RTE_OUT_OF_BOUNDS` | An array accession was attempted, but the index was out of bounds | No, but can be avoided by checking the index against the array's size |

#### MAM Errors

| Code | Name | Description | Recoverable? |
| ---- | ---- | ----------- | ------------ |
| `0xE0` | `SRE_MAM_BAD_ALLOC` | An error occurred when requesting memory from the OS | No |
| `0xE5` | `SRE_MAM_REFERENCE_LIMIT` | The number of references to the resource has exceeded the limit (2^32 - 1) | No |
| `0xE9` | `SRE_MAM_INIT_ERROR` | There was an error in initializing the MAM; most likely, a failed call to `operator new` | No |
| `0xEA` | `SRE_MAM_UNDEFINED_RESOURCE_ERROR` | A resource was requested which was not allocated by the MAM | No |
| `0xEB` | `SRE_MAM_OPERATION_ERROR` | The MAM could not perform the requested operation | No |
