# eclectic general purpose programming language

## Build and run

```
make

./eclectic < your_eclictic_code.txt
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

## Language features(both planned and implemented) 

### MVP: 
- assignment
- basic arithmetic operations
    - addition
    - subtraction
    - multiplication
    - division
    - mod
    - increment
    - decrement

- flow control - if/else
- loops while(maybe for(maybe combine them like in golang))
- print() function 
- functions
- main function 

### Nice to have:
- structs
- multiline comments
- basic binary operations


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
- int
- bool
- float/double - ADVANCED
- string - ADVANCED
- char - ADVANCED
- array - ADVANCED
- struct - ADVANCED
