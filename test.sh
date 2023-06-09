#!/bin/bash

TEST_DIR=test
SRC=eclectic

# expand for more test types here and in switch case
TEST_GROUPS_DEFAULT=(syntax semantic codegen)

TEST_TYPES_DEFAULT=(ok err warn)
TEST_TYPES_RETURNS_DEFAULT=(0 1 2)

TEST_TYPES=()
TEST_TYPES_RETURNS=()
TEST_GROUPS=()

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -o|--ok) TEST_TYPES+=(ok) TEST_TYPES_RETURNS+=(0) ;;
        -e|--error) TEST_TYPES+=(err) TEST_TYPES_RETURNS+=(1) ;;
        -w|--warning) TEST_TYPES+=(warn) TEST_TYPES_RETURNS+=(2) ;;
        # expand for mor test types here
        syntax) TEST_GROUPS+=(syntax) ;;
        semantic) TEST_GROUPS+=(semantic) ;;
        codegen) TEST_GROUPS+=(codegen) ;;
    esac 
    shift
done

if [ ${#TEST_GROUPS[@]} -eq 0 ]; then
    TEST_GROUPS=("${TEST_GROUPS_DEFAULT[@]}")
fi

if [ ${#TEST_TYPES[@]} -eq 0 ]; then
    TEST_TYPES_RETURNS=("${TEST_TYPES_RETURNS_DEFAULT[@]}")
    TEST_TYPES=("${TEST_TYPES_DEFAULT[@]}")
fi

#echo ${TEST_GROUPS[@]}
#echo ${TEST_TYPES[@]}


for test_group_idx in ${!TEST_GROUPS[@]}; do
    for test_type_idx in ${!TEST_TYPES[@]}; do
        file_path=$TEST_DIR/${TEST_GROUPS[$test_group_idx]}/*-${TEST_TYPES[test_type_idx]}-*
        for file in $file_path; do
            if [ ! -e "$file" ]; then
                continue
            fi
            return_value=${TEST_TYPES_RETURNS[$test_type_idx]}            
            ./$SRC < $file 1>/dev/null 2>/dev/null
            RETURN_VALUE=$?

            if [ $RETURN_VALUE -eq $return_value ]
            then
                if [ $RETURN_VALUE -eq 0 ] && [ "${TEST_GROUPS[test_group_idx]}" == "codegen" ]
                then
                    wat2wasm output.wat -o program.wasm 
                    OUTPUT=$(node program.js | tr '\n' ' ') 
                    DEFINED_OUTPUT=$(grep "// RETURN:" $file | cut -d ':' -f2 | tr '\n' ' ')
                    #echo "$OUTPUT"
                    if [ "$OUTPUT" == "$DEFINED_OUTPUT" ] 
                    then
                        echo -e "[\033[92mPASSED\033[0m] $file"
                    else 
                        echo -e "[\033[91mFAILED\033[0m] $file"
                    fi
                else
                    echo -e "[\033[92mPASSED\033[0m] $file"
                fi
            else
                echo -e "[\033[91mFAILED\033[0m] $file"
            fi
            #rm -f output.wat
            #rm -f program.wasm
        done
    done
done

