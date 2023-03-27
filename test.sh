#!/bin/bash

TEST_DIR=test

# expand for more test types here and in switch case
TEST_GROUPS_DEFAULT=(syntax semantic)

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
            ./text < $file 1>/dev/null 2>/dev/null
            if [ $? -eq $return_value ]
            then
                echo -e "[\033[92mPASSED\033[0m] $file"
            else
                echo -e "[\033[91mFAILED\033[0m] $file"
            fi
            
        done
    done
done

