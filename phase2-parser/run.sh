#!/bin/bash

# Build the lexer
echo "Building the lexer..."
make clean > /dev/null 2>&1
make > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

echo "Build successful. Running tests..."
echo "=========================================="

passed=0
failed=0

mkdir -p test/output

for file in test/*.c; do
    filename=$(basename "$file" .c)
    expected_file="test/expected/${filename}.out"
    actual_file="test/output/${filename}.out"
    
    ./syntax_analyzer "$file" > "$actual_file" 2>&1
    
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

if [ $failed -ne 0 ]; then
    exit 1
fi
exit 0
