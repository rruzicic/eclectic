# eclectic general purpose programming language

## Build and run

Firstly run `make` to generate binaries, then run the following commands:
```
./eclectic < your_eclictic_code.txt

wat2wasm output.wat -o program.wasm

node program.js
```

## Test

`./test.sh [TEST_GROUP] [TEST_TYPE]`

[TEST_GROUP] - test groups are defined as subdirectiories of `test/` directory

[TEST_TYPE] 
- -o|--ok -run just the OK tests
- -e|--error -run just the ERROR tests
- -w|--warning -run just the WARNING tests

## Dependencies used

- GNU Bison 3.5.1
- flex 2.6.4
- gcc 9.4.0
- node 17.8.0
- wat2wasm 1.0.13

## Language features(both planned and implemented) 

### MVP: 
- [x] assignment 
- [x] basic arithmetic operations 
    - addition
    - subtraction
    - multiplication
    - division
    - mod
    - increment
    - decrement

- [x] flow control - if/else
- loops while(maybe for(maybe combine them like in golang))
- [x] print() function 
- [x] functions
- [x] main function 
- global vars

### Nice to have:
- structs
- [x] multiline comments
- basic binary operations
- VSCode syntax highlighting


### Advanced requirements:
- grouped switch cases(PASCAL)
- type inference (golang := operator) 
- native strings as types
- double/float types
- array types
- implicit cast
- explicit cast
- function overload


### Types:
- [x] int
- [x] bool
- float/double
- string - ADVANCED
- array - ADVANCED
- struct - ADVANCED
