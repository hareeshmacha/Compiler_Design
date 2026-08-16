/**
 * @file token.cpp
 * @brief Implementation of token mapping and lookup functions.
 *
 * Provides static hash maps for O(1) constant time lookup of reserved words
 * and operators. This allows the lexer to simply match any identifier pattern
 * and cleanly resolve whether it's a keyword or a plain identifier.
 */

#include "token_mapper.hpp"

// ============================================================================
// Internal Lookup Tables
// ============================================================================

static const std::unordered_map<std::string, TokenType> keyword_map = {
    // Primitive types
    {"int", TokenType::INT}, {"char", TokenType::CHAR}, {"float", TokenType::FLOAT},
    {"double", TokenType::DOUBLE}, {"void", TokenType::VOID}, {"short", TokenType::SHORT},
    {"long", TokenType::LONG}, {"signed", TokenType::SIGNED}, {"unsigned", TokenType::UNSIGNED},
    
    // Composite types
    {"struct", TokenType::STRUCT}, {"enum", TokenType::ENUM}, {"union", TokenType::UNION},
    {"class", TokenType::CLASS},
    
    // Access modifiers & OO
    {"public", TokenType::PUBLIC}, {"private", TokenType::PRIVATE},
    {"protected", TokenType::PROTECTED}, {"this", TokenType::THIS},
    
    // Storage class & modifiers
    {"static", TokenType::STATIC}, {"typedef", TokenType::TYPEDEF}, {"auto", TokenType::AUTO},
    
    // Control flow
    {"if", TokenType::IF}, {"else", TokenType::ELSE}, {"for", TokenType::FOR},
    {"while", TokenType::WHILE}, {"do", TokenType::DO}, {"until", TokenType::UNTIL},
    {"switch", TokenType::SWITCH}, {"case", TokenType::CASE}, {"default", TokenType::DEFAULT},
    {"break", TokenType::BREAK}, {"continue", TokenType::CONTINUE}, {"goto", TokenType::GOTO},
    {"return", TokenType::RETURN},
    
    // Custom I/O & Memory mapping
    {"printf", TokenType::PRINTF}, {"scanf", TokenType::SCANF},
    {"malloc", TokenType::MALLOC}, {"free", TokenType::FREE},
    {"calloc", TokenType::CALLOC}, {"realloc", TokenType::REALLOC},
    
    // File Manipulation
    {"FILE", TokenType::FILE_KEYWORD}, {"fopen", TokenType::FOPEN}, {"fclose", TokenType::FCLOSE},
    {"fread", TokenType::FREAD}, {"fwrite", TokenType::FWRITE}, {"fprintf", TokenType::FPRINTF},
    {"fscanf", TokenType::FSCANF}, {"fgets", TokenType::FGETS}, {"fputs", TokenType::FPUTS},
    {"feof", TokenType::FEOF},
    
    // Boolean literals
    {"true", TokenType::BOOL_LITERAL}, {"false", TokenType::BOOL_LITERAL}
};

static const std::unordered_map<std::string, TokenType> operator_map = {
    {"->", TokenType::ARROW_OP}, {".", TokenType::DOT_OP}, {"?", TokenType::QUESTION_OP},
    {"...", TokenType::ELLIPSIS_OP}, {"::", TokenType::SCOPE_RES_OP},
    
    {"=", TokenType::ASSIGN_OP}, {"+=", TokenType::PLUS_ASSIGN_OP}, {"-=", TokenType::MINUS_ASSIGN_OP},
    {"*=", TokenType::STAR_ASSIGN_OP}, {"/=", TokenType::DIVIDE_ASSIGN_OP}, {"%=", TokenType::MOD_ASSIGN_OP},
    {"&=", TokenType::AMP_ASSIGN_OP}, {"|=", TokenType::PIPE_ASSIGN_OP}, {"^=", TokenType::CARET_ASSIGN_OP},
    {"<<=", TokenType::LSHIFT_ASSIGN_OP}, {">>=", TokenType::RSHIFT_ASSIGN_OP},
    
    {"&&", TokenType::LOGICAL_AND_OP}, {"||", TokenType::LOGICAL_OR_OP}, {"!", TokenType::LOGICAL_NOT_OP},
    {"==", TokenType::EQ_OP}, {"!=", TokenType::NE_OP}, {"<", TokenType::LT_OP},
    {">", TokenType::GT_OP}, {"<=", TokenType::LE_OP}, {">=", TokenType::GE_OP},
    
    {"++", TokenType::INC_OP}, {"--", TokenType::DEC_OP}, {"+", TokenType::PLUS_OP},
    {"-", TokenType::MINUS_OP}, {"*", TokenType::STAR_OP}, {"/", TokenType::DIVIDE_OP},
    {"%", TokenType::MOD_OP}, {"&", TokenType::AMP_OP}, {"|", TokenType::PIPE_OP},
    {"^", TokenType::CARET_OP}, {"~", TokenType::TILDE_OP}, {"<<", TokenType::LSHIFT_OP},
    {">>", TokenType::RSHIFT_OP},
    
    {",", TokenType::COMMA_OP}, {";", TokenType::SEMICOLON_OP}, {":", TokenType::COLON_OP},
    {"(", TokenType::OPEN_PAREN}, {")", TokenType::CLOSE_PAREN},
    {"{", TokenType::OPEN_BRACE}, {"}", TokenType::CLOSE_BRACE},
    {"[", TokenType::OPEN_BRACKET}, {"]", TokenType::CLOSE_BRACKET}
};

static const std::unordered_map<TokenType, std::string> type_to_string_map = {
    // A subset initialization here mapping types to neat strings for the stdout table
    // (We will use lowercase string literals for cleaner visual output)
    {TokenType::IDENTIFIER, "identifier"}, {TokenType::INT_LITERAL, "int_literal"},
    {TokenType::FLOAT_LITERAL, "float_literal"}, {TokenType::CHAR_LITERAL, "char_literal"},
    {TokenType::STRING_LITERAL, "string_literal"}, {TokenType::BOOL_LITERAL, "bool_literal"},
    {TokenType::INT, "int"}, {TokenType::CHAR, "char"}, {TokenType::FLOAT, "float"},
    {TokenType::DOUBLE, "double"}, {TokenType::VOID, "void"}, {TokenType::SHORT, "short"},
    {TokenType::LONG, "long"}, {TokenType::SIGNED, "signed"}, {TokenType::UNSIGNED, "unsigned"},
    {TokenType::STRUCT, "struct"}, {TokenType::ENUM, "enum"}, {TokenType::UNION, "union"},
    {TokenType::CLASS, "class"}, {TokenType::PUBLIC, "public"}, {TokenType::PRIVATE, "private"},
    {TokenType::PROTECTED, "protected"}, {TokenType::THIS, "this"}, {TokenType::STATIC, "static"},
    {TokenType::TYPEDEF, "typedef"}, {TokenType::AUTO, "auto"}, {TokenType::IF, "if"},
    {TokenType::ELSE, "else"}, {TokenType::FOR, "for"}, {TokenType::WHILE, "while"},
    {TokenType::DO, "do"}, {TokenType::UNTIL, "until"}, {TokenType::SWITCH, "switch"},
    {TokenType::CASE, "case"}, {TokenType::DEFAULT, "default"}, {TokenType::BREAK, "break"},
    {TokenType::CONTINUE, "continue"}, {TokenType::GOTO, "goto"}, {TokenType::RETURN, "return"},
    {TokenType::PRINTF, "printf"}, {TokenType::SCANF, "scanf"}, {TokenType::MALLOC, "malloc"},
    {TokenType::FREE, "free"}, {TokenType::CALLOC, "calloc"}, {TokenType::REALLOC, "realloc"},
    {TokenType::FILE_KEYWORD, "file_keyword"}, {TokenType::FOPEN, "fopen"}, {TokenType::FCLOSE, "fclose"},
    {TokenType::FREAD, "fread"}, {TokenType::FWRITE, "fwrite"}, {TokenType::FPRINTF, "fprintf"},
    {TokenType::FSCANF, "fscanf"}, {TokenType::FGETS, "fgets"}, {TokenType::FPUTS, "fputs"},
    {TokenType::FEOF, "feof"}, {TokenType::ARROW_OP, "arrow_op"}, {TokenType::DOT_OP, "dot_op"},
    {TokenType::QUESTION_OP, "question_op"}, {TokenType::ELLIPSIS_OP, "ellipsis_op"},
    {TokenType::SCOPE_RES_OP, "scope_res_op"}, {TokenType::ASSIGN_OP, "assign_op"},
    {TokenType::PLUS_ASSIGN_OP, "plus_assign_op"}, {TokenType::MINUS_ASSIGN_OP, "minus_assign_op"},
    {TokenType::STAR_ASSIGN_OP, "star_assign_op"}, {TokenType::DIVIDE_ASSIGN_OP, "divide_assign_op"},
    {TokenType::MOD_ASSIGN_OP, "mod_assign_op"}, {TokenType::AMP_ASSIGN_OP, "amp_assign_op"},
    {TokenType::PIPE_ASSIGN_OP, "pipe_assign_op"}, {TokenType::CARET_ASSIGN_OP, "caret_assign_op"},
    {TokenType::LSHIFT_ASSIGN_OP, "lshift_assign_op"}, {TokenType::RSHIFT_ASSIGN_OP, "rshift_assign_op"},
    {TokenType::LOGICAL_AND_OP, "logical_and_op"}, {TokenType::LOGICAL_OR_OP, "logical_or_op"},
    {TokenType::LOGICAL_NOT_OP, "logical_not_op"}, {TokenType::EQ_OP, "eq_op"},
    {TokenType::NE_OP, "ne_op"}, {TokenType::LT_OP, "lt_op"}, {TokenType::GT_OP, "gt_op"},
    {TokenType::LE_OP, "le_op"}, {TokenType::GE_OP, "ge_op"}, {TokenType::INC_OP, "inc_op"},
    {TokenType::DEC_OP, "dec_op"}, {TokenType::PLUS_OP, "plus_op"}, {TokenType::MINUS_OP, "minus_op"},
    {TokenType::STAR_OP, "star_op"}, {TokenType::DIVIDE_OP, "divide_op"}, {TokenType::MOD_OP, "mod_op"},
    {TokenType::AMP_OP, "amp_op"}, {TokenType::PIPE_OP, "pipe_op"}, {TokenType::CARET_OP, "caret_op"},
    {TokenType::TILDE_OP, "tilde_op"}, {TokenType::LSHIFT_OP, "lshift_op"}, {TokenType::RSHIFT_OP, "rshift_op"},
    {TokenType::COMMA_OP, "comma_op"}, {TokenType::SEMICOLON_OP, "semicolon_op"},
    {TokenType::COLON_OP, "colon_op"}, {TokenType::OPEN_PAREN, "open_paren_op"},
    {TokenType::CLOSE_PAREN, "close_paren_op"}, {TokenType::OPEN_BRACE, "open_brace_op"},
    {TokenType::CLOSE_BRACE, "close_brace_op"}, {TokenType::OPEN_BRACKET, "open_bracket_op"},
    {TokenType::CLOSE_BRACKET, "close_bracket_op"}
};

// ============================================================================
// Public Interface Definitions
// ============================================================================

std::string token_type_to_string(TokenType type) {
    auto it = type_to_string_map.find(type);
    if (it != type_to_string_map.end()) {
        return it->second;
    }
    return "UNKNOWN";
}

std::optional<TokenType> get_keyword_type(const std::string& str) {
    auto it = keyword_map.find(str);
    if (it != keyword_map.end()) {
        return it->second;
    }
    return std::nullopt;
}

std::optional<TokenType> get_operator_type(const std::string& str) {
    auto it = operator_map.find(str);
    if (it != operator_map.end()) {
        return it->second;
    }
    return std::nullopt;
}
