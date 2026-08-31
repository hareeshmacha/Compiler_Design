#ifndef ERROR_HANDLER_HPP
#define ERROR_HANDLER_HPP

#include <string>

// Helper to report lexical errors found by Flex
void reportError(int line, const std::string& lexeme, const std::string& msg);

#endif
