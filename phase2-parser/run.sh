#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: ./run.sh <executable_path>"
    exit 1
fi

EXEC="$1"

if [ ! -f "$EXEC" ]; then
    echo "Executable $EXEC not found!"
    exit 1
fi

echo "Running tests using $EXEC..."
echo "=========================================="

passed=0
failed=0

for file in test/*.c; do
    filename=$(basename "$file" .c)
    expected_file="test/expected/${filename}.out"
    actual_file="test/output/${filename}.out"
    
    "$EXEC" "$file" > "$actual_file" 2>&1
    
    if diff -q "$expected_file" "$actual_file" > /dev/null; then
        echo -e "[\033[32mPASS\033[0m] $filename"
        ((passed++))
    else
        echo -e "[\033[31mFAIL\033[0m] $filename - Output does not match expected!"
        echo "--- DIFF (first 10 lines) ---"
        diff "$expected_file" "$actual_file" | head -n 10
        echo "-----------------------------"
        ((failed++))
    fi
done

echo "=========================================="
echo "Tests Passed: $passed"
echo "Tests Failed: $failed"

if [ $failed -eq 0 ]; then
    exit 0
else
    exit 1
fi
