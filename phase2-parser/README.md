# Phase 1: Lexical Analyzer

This directory contains the Lexical Analyzer (Scanner) for our custom C-like programming language. It represents the very first phase of the compiler pipeline. Built in C++ using `flex`, this lexer categorizes raw source code into a structured stream of tokens.

---

## Features Implemented

We have meticulously implemented **every required feature**, spanning from standard C constructs to advanced object-oriented features:

### 1. Basic Constructs
- **Arithmetic & Logical Operators**: `+`, `-`, `*`, `/`, `%`, `++`, `--`, `==`, `!=`, `<`, `>`, `<=`, `>=`, `&&`, `||`, `!`
- **Bitwise Operators**: `&`, `|`, `^`, `~`, `<<`, `>>`
- **Control Flow**: `if`, `else`, `for`, `while`, `do`, `switch`, `case`, `default`, `break`, `continue`, `goto`, `return`
- **Data Types & Storage**: `int`, `char`, `float`, `double`, `void`, `short`, `long`, `signed`, `unsigned`, `static`
- **Literals**: Integer, floating-point, character (`'\n'`, `'\x41'`), string literals, binary (`0b1010`), and booleans (`true`, `false`)
- **Comments**: Correctly filters single-line (`//`) and multi-line block comments (`/* ... */`)

### 2. Advanced C Features
- **Pointers & References**: Single pointers (`*`), multi-level pointers (`**`, `***`), and references (`&`)
- **Memory Management**: `malloc`, `free`, `calloc`, `realloc`
- **Variable Arguments**: Ellipsis (`...`) for variadic functions
- **Structs & Typedefs**: `struct`, `typedef`, `enum`, `union`
- **File Manipulation**: `FILE`, `fopen`, `fclose`, `fread`, `fwrite`, `fprintf`, `fscanf`, `fgets`, `fputs`, `feof`

### 3. Object-Oriented & Custom Features
- **Classes & Objects**: `class`, `public`, `private`, `protected`, `this`
- **Scope Resolution**: `::`
- **Modern C++ Elements**: Lambdas (via `[`, `]`, `(`, `)`, `->`) and `auto`
- **Custom Control Flow**: `until` loops (acting as inverse `while` loops)

---

## Elegant Architecture & Simplicity

This lexer is engineered to be as simple, clean, and modern as possible. Instead of messy and complicated `if/else` logic chains, our lexer utilizes a highly optimized **Component-Based Architecture**:

- **O(1) Keyword Resolution**: Inside `token_mapper.cpp`, we use modern C++ `std::unordered_map` hash tables to look up keywords instantly. This keeps the code incredibly clean and highly readable.
- **Robust Error Handling**: Our lexer never crashes on invalid inputs. `error_handler.cpp` neatly intercepts all lexical errors (like unterminated strings or invalid escapes) into a safe `std::vector` and cleanly reports them with precise line numbers at the end of execution.

---

## Directory Structure

The project is structured into logical components to ensure clean separation of concerns and maintainability:

```text
phase1-lexer/
├── src/
│   ├── lexer.l             # The core Flex regular expressions
│   ├── token_mapper.hpp    # Definitions of Token struct, TokenType enum
│   ├── token_mapper.cpp    # O(1) keyword and operator mapping implementation
│   ├── error_handler.hpp   # Definitions for non-crashing error tracking
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
│   └── test11_lexical_errors.c  # Edge cases (unterminated strings, invalid literals)
├── makefile                # Compilation instructions
└── run.sh                  # Automation script to compile and run all tests
```

---

## Rigorous Testing

This lexer is built to be robust and fault-tolerant. 

- **Granular Testing**: We designed 11 specific edge-case test files (located in `/test/`) to rigorously test every single feature, including complex pointer chains, object-oriented constructs, file I/O operations, and lambda syntax.
- **Error Recovery**: The lexer is tested against intentionally malformed code (such as unterminated string literals, invalid escape sequences, and unterminated block comments) to ensure it correctly intercepts and reports errors without crashing.

---

## Build & Run Instructions

**Prerequisites**: You must have `g++`, `flex`, and `make` installed on a Linux/Unix system (or WSL/MSYS2 on Windows).

1. **Build the Lexer**
   Navigate to this directory and compile:
   ```bash
   make
   ```

2. **Run the Automated Tests**
   Execute all 11 test cases at once:
   ```bash
   bash run.sh
   ```

3. **Run a Single File**
   If you want to lex a specific source file manually:
   ```bash
   ./lexer test/test01_arithmetic.c
   ```

---

## Expected Output

If the source code is completely valid, the lexer will generate a cleanly formatted table mapping each Lexeme to its Token type:

```text
Lexeme                         Token               
------                         -----               
if                             if                  
(                              open_paren_op       
a                              identifier          
==                             eq_op               
5                              int_literal         
)                              close_paren_op      
```

If lexical errors are found, the lexer suppresses the table and instead reports all issues:
```text
Lexical analysis failed: 2 error(s) found.
Line 5: Unterminated string literal near '"Hello '
Line 10: Illegal character near '@'
```
