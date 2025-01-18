#!/usr/bin/env bash

if [[ $1 == "python" ]]; then
    # run python files
    python_files=$(find python -maxdepth 1 -type f)
    for file in $python_files
    do
        if [[ $2 == "test" ]]; then
            failed=$(python3 $file test &>/dev/null && echo $?)
            if [[ $failed != 0 ]]; then
                echo "$file test failed"
            else
                echo "$file tested successfully"
            fi
        fi
        if [[ $2 == "input" ]]; then
            failed=$(python3 $file input &>/dev/null && echo $?)
            if [[ $failed != 0 ]]; then
                echo "$file compilation or execution failed"
            else
                echo "$file compiled and executed successfully"
            fi
        fi
    done
fi

if [[ $1 == "zig" ]]; then
    # run zig files
    zig_files=$(find zig -maxdepth 1 -type f)
    for file in $zig_files
    do
        if [[ $2 == "test" ]]; then
            failed=$(zig test $file &>/dev/null && echo $?)
            if [[ $failed != 0 ]]; then
                echo "$file test failed"
            else
                echo "$file tested successfully"
            fi
        fi
        if [[ $2 == "input" ]]; then
            failed=$(zig run -ODebug $file &>/dev/null && echo $?)
            if [[ $failed != 0 ]]; then
                echo "$file compilation or execution failed"
            else
                echo "$file compiled and executed successfully"
            fi
        fi
    done
fi
