#!/usr/bin/env bash

# run python files
pushd ./python &>/dev/null
python_files=$(find . -maxdepth 1 -type f)
for file in $python_files
do
    if [[ $1 == "test" ]]; then
        failed=$(python3 $file test &>/dev/null && echo $?)
        if [[ $failed != 0 ]]; then
            echo "$file failed"
        fi
    fi
    if [[ $1 == "input" ]]; then
        failed=$(python3 $file input &>/dev/null && echo $?)
        if [[ $failed != 0 ]]; then
            echo "$file failed"
        fi
    fi
done
popd &>/dev/null

# run zig files
# pushd ./zig/src &>/dev/null
# zig_files=$(find . -maxdepth 1 -type f)
# for file in $zig_files
# do
#     if [[ $1 == "test" ]]; then
#         failed=$(zig test $file &>/dev/null && echo $?)
#         if [[ $failed != 0 ]]; then
#             echo "$file failed"
#         fi
#     fi
#     if [[ $1 == "input" ]]; then
#         failed=$(zig build-exe -OReleaseFast $file &>/dev/null && ./$(echo "$filename" | cut -f 1 -d '.') && echo $?)
#         if [[ $failed != 0 ]]; then
#             echo "$file failed"
#         fi
#     fi
# done
# popd &>/dev/null
