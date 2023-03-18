#!/bin/bash

# OK tests
for file in test/syntax/*-ok-*; do
    #echo "$file"
    ./text <$file 1>/dev/null 2>/dev/null
    
    if [ $? -eq 0 ] 
    then
        echo -e "[\033[92mPASSED\033[0m] $file"
    else
        echo -e "[\033[91mFAILED\033[0m] $file"
    fi

    #echo "$?"
done

# ERR tests
for file in test/syntax/*-err-*; do
    ./text <$file 1>/dev/null 2>/dev/null
    
    if [ $? -eq 1 ] 
    then
        echo -e "[\033[92mPASSED\033[0m] $file"
    else
        echo -e "[\033[91mFAILED\033[0m] $file"
    fi

    #echo "$?"
done

