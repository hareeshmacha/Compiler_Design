#ifndef SEMANTIC_TYPES_HPP
#define SEMANTIC_TYPES_HPP

#include <string>

// Allocated by Lexer, handed to Parser. Parser sets semantic_role if needed.
struct ParsedToken {
    std::string lexeme;
    std::string default_token;  // E.g., "identifier", "if"
    std::string semantic_role;  // E.g., "PROCEDURE" or "INT_POINTER"
    int line_num;

    ParsedToken(std::string l, std::string d, int line) 
        : lexeme(l), default_token(d), semantic_role(""), line_num(line) {}
};

enum class SymRole {
    VARIABLE,
    PROCEDURE,
    PARAMETER,
    STRUCT_TAG,
    CLASS_TAG,
    ENUM_TAG,
    UNION_TAG,
    TYPEDEF_NAME,
    ENUM_CONST,
    LABEL
};

// Struct used by Bison to accumulate pointer/array modifiers during parsing
struct TypeBuilder {
    std::string base_type;
    int pointer_depth = 0;
    bool is_array = false;
    bool is_function = false;

    std::string resolve() const {
        if (is_function) return "PROCEDURE";
        std::string res = base_type;
        if (is_array) res += "_ARRAY";
        for (int i = 0; i < pointer_depth; ++i) {
            res += "_POINTER";
        }
        return res;
    }
};

#endif
