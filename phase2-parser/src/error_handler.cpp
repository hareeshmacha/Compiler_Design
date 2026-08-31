#include "error_handler.hpp"
#include <iostream>

extern bool parse_error;

void reportError(int line, const std::string& lexeme, const std::string& msg) {
    std::cerr << "Lexical error on line " << line << ": " << msg << " near '" << lexeme << "'\n";
    parse_error = true;
}
