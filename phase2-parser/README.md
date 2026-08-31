# Phase 2: Syntax Analyzer (Parser)

This directory contains the Syntax Analyzer (Parser) for our custom C-like programming language. It represents the second phase of the compiler pipeline. Built in C++ using `flex` and `bison`, this parser verifies the grammatical structure of the source code and maps variables/functions to their semantic roles.

---

## Features Implemented

We have meticulously implemented grammar rules spanning from standard C constructs to advanced object-oriented features:

### 1. Basic Constructs
- **Arithmetic & Logical Operators**: Full expression trees with correct operator precedence (e.g., `+`, `-`, `*`, `&&`, `==`).
- **Control Flow**: `if`, `else`, `for`, `while`, `do`, `switch`, `case`, `default`, `break`, `continue`, `return`.
- **Custom Control Flow**: The `until` loop, acting as an inverse `while` loop.
- **Literals & Assignment**: Integer, floating-point, boolean literals, and complex assignment operations (`+=`, `<<=`).

### 2. Advanced C Features
- **Pointers & Memory**: Pointer declarations (`int* ptr`), memory allocation (`malloc`, `free`), and `sizeof()`.
- **Structs & Type Casts**: Struct definitions, instantiations, and explicit type casts `(int)`.
- **File Manipulation**: `FILE*`, `fopen`, `fclose`, `fprintf`, `fscanf`, etc.

### 3. Object-Oriented Features
- **Classes & Inheritance**: `class`, `public`, `private`, `protected`.
- **Scope & Members**: Scope resolution `::` and member access `.` / `->`.
- **Lambdas**: Parsing inline functions `[](int x) { ... }`.

---

## Elegant Architecture & Simplicity

This parser is engineered to be as simple, clean, and modern as possible. Instead of building massive, confusing Abstract Syntax Trees (ASTs), our parser utilizes a highly optimized **Symbol Table Architecture**:

- **Intelligent Token Tracking**: The `ParsedToken` class tracks lexical data directly from Flex.
- **Object-Oriented Symbol Table**: Instead of global arrays, we implemented a robust `SymbolTable` class with scope management (`enterScope`, `exitScope`). When Bison parses a declaration (like `int myVar;`), it adds it to the current scope. When it sees an identifier, it queries the `SymbolTable` to resolve its semantic role!
- **Lexer Hack**: The Lexer talks to the Symbol Table to distinguish between normal identifiers and user-defined classes/structs (returning `TYPE_NAME`), ensuring the grammar remains ambiguity-free.

---

## Directory Structure

The project is structured into logical components to ensure clean separation of concerns:

```text
phase2-parser/
├── src/
│   ├── lexer.l             # The core Flex regular expressions
│   ├── parser.y            # The Bison grammar rules
│   ├── semantic_types.hpp  # Definitions of ParsedToken and semantic logic
│   ├── symbol_table.hpp    # Definitions for Scope Management
│   ├── symbol_table.cpp    # Symbol Table implementation
│   ├── error_handler.cpp   # Error logging implementation
│   └── main.cpp            # Driver code to parse files and print the table
├── test/
│   ├── test01_arithmetic.c      # Arithmetic & variable tests
│   ├── test02_control_flow.c    # Loops and switch logic
│   ├── test03_until_loop.c      # Testing custom 'until' keyword
│   ├── test04_arrays_multi.c    # Multidimensional arrays
│   ├── test05_pointers_refs.c   # Multi-level pointers (***ptr)
│   ├── test06_structs_enums.c   # Structs, Unions, Enums, Typedefs
│   ├── test07_dynamic_memory.c  # malloc, free, calloc
│   ├── test08_classes_oop.c     # OOP features (class, public, this)
│   ├── test09_lambdas_varargs.c # Lambdas and Ellipsis (...)
│   ├── test10_file_io.c         # fopen, fclose, FILE
│   └── test11_lexical_errors.c  # Edge cases that trigger syntax errors
├── makefile                # Compilation instructions
└── run.sh                  # Automation script to compile and run all tests
```

---

## Rigorous Testing

We designed 11 specific edge-case test files (located in `/test/`) to rigorously test every single feature, including complex pointer chains, object-oriented constructs, and lambda syntax. The `run.sh` script automatically diffs the output against the expected baselines in `test/expected/`.

---

## Build & Run Instructions

**Prerequisites**: You must have `g++`, `flex`, `bison`, and `make` installed on a Linux/Unix system (or WSL/MSYS2 on Windows).

1. **Build the Parser**
   Navigate to this directory and compile:
   ```bash
   make
   ```

2. **Run the Automated Tests**
   Execute all 11 test cases at once:
   ```bash
   bash run.sh ./syntax_analyzer
   ```

3. **Run a Single File**
   If you want to parse a specific source file manually:
   ```bash
   ./syntax_analyzer test/test01_arithmetic.c
   ```

---

## Expected Output

If the source code is completely valid, the parser will generate a cleanly formatted table mapping each Token to its resolved semantic Token_Type:

```text
Token                    | Token_Type
-------------------------|---------------
int                      | INT
main                     | PROCEDURE
(                        | (
)                        | )
{                        | {
int                      | INT
a                        | VARIABLE
=                        | =
15                       | INT_LITERAL
```

If the input code is structurally invalid or contains lexical errors, the parser prints the syntax errors to standard error and halts:
```text
Lexical error on line 5: Multi-character char literal near 'XYZ'
Syntax error on line 5: syntax error near ';'
```
