#include <iostream>
#include <iomanip>
#include <vector>
#include "token_mapper.hpp"
#include "error_handler.hpp"

// External Flex Declarations
extern int yylex();
extern FILE* yyin;

// Global Token Vector
std::vector<Token> tokens;

void printTokens(const std::vector<Token>& toks) {
    std::cout << std::left << std::setw(30) << "Lexeme" << std::setw(20) << "Token" << "\n";
    std::cout << std::left << std::setw(30) << "------" << std::setw(20) << "-----" << "\n";
    for (const auto& t : toks) {
        std::cout << std::left << std::setw(30) << t.lexeme
                  << std::setw(20) << token_type_to_string(t.type) << "\n";
    }
}

void printDiagnostics() {
    std::cerr << "Lexical analysis failed: " << diagnostics.size() << " error(s) found.\n";
    for (const auto& err : diagnostics) {
        std::cerr << "Line " << err.line << ": " << err.message << " near '" << err.lexeme << "'\n";
    }
}

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "Usage: " << argv[0] << " <source-file>\n";
        return 1;
    }

    FILE* f = fopen(argv[1], "r");
    if (!f) {
        std::cerr << "Error: could not open file '" << argv[1] << "'\n";
        return 1;
    }

    yyin = f;
    yylex();
    fclose(f);

    if (hasErrors()) {
        printDiagnostics();
        return 1;
    }

    printTokens(tokens);
    return 0;
}
