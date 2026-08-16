#!/bin/bash

# Build the lexer
echo "Building the lexer..."
make clean
make

if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

echo "Build successful. Running tests..."
echo "=========================================="

for file in test/*.c; do
    echo "--- Testing: $file ---"
    ./lexer "$file"
    echo "=========================================="
done
