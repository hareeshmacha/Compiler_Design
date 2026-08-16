/**
 * @file token.hpp
 * @brief Defines the Token structure and TokenType enumeration for the Lexical Analyzer.
 *
 * This header contains the fundamental building blocks of the lexer: the definitions of
 * all possible token types (keywords, operators, literals) and the core `Token` struct
 * used to pass data to subsequent compiler phases.
 */

#ifndef TOKEN_HPP
#define TOKEN_HPP

#include <string>
#include <optional>
#include <unordered_map>

/**
 * @enum TokenType
 * @brief Categorizes every unique lexeme into a specific structural role.
 *
 * Instead of broad categories (like "KEYWORD" or "OPERATOR"), each keyword and operator
 * gets its own distinct TokenType. This mirrors modern parser requirements.
 */
enum class TokenType {
    // ---- Literals & Identifiers ----
    IDENTIFIER,
    INT_LITERAL,
    FLOAT_LITERAL,
    CHAR_LITERAL,
    STRING_LITERAL,
    BOOL_LITERAL,

    // ---- Primitive Types ----
    INT, CHAR, FLOAT, DOUBLE, VOID, SHORT, LONG, SIGNED, UNSIGNED,

    // ---- Composite Types ----
    STRUCT, ENUM, UNION, CLASS,

    // ---- Access Modifiers & Object-Oriented Features ----
    PUBLIC, PRIVATE, PROTECTED, THIS,

    // ---- Storage Class & Modifiers ----
    STATIC, TYPEDEF, AUTO,

    // ---- Control Flow ----
    IF, ELSE, FOR, WHILE, DO, UNTIL, SWITCH, CASE, DEFAULT, BREAK, CONTINUE, GOTO, RETURN,

    // ---- I/O, Memory Allocation, & File Manipulation ----
    PRINTF, SCANF, 
    MALLOC, FREE, CALLOC, REALLOC,
    FILE_KEYWORD, FOPEN, FCLOSE, FREAD, FWRITE, FPRINTF, FSCANF, FGETS, FPUTS, FEOF,

    // ---- Operators ----
    ARROW_OP, DOT_OP, QUESTION_OP, ELLIPSIS_OP, SCOPE_RES_OP,

    ASSIGN_OP, PLUS_ASSIGN_OP, MINUS_ASSIGN_OP, STAR_ASSIGN_OP, DIVIDE_ASSIGN_OP,
    MOD_ASSIGN_OP, AMP_ASSIGN_OP, PIPE_ASSIGN_OP, CARET_ASSIGN_OP, LSHIFT_ASSIGN_OP, RSHIFT_ASSIGN_OP,

    LOGICAL_AND_OP, LOGICAL_OR_OP, LOGICAL_NOT_OP,
    EQ_OP, NE_OP, LT_OP, GT_OP, LE_OP, GE_OP,

    INC_OP, DEC_OP,
    PLUS_OP, MINUS_OP, STAR_OP, DIVIDE_OP, MOD_OP,
    AMP_OP, PIPE_OP, CARET_OP, TILDE_OP, LSHIFT_OP, RSHIFT_OP,

    COMMA_OP, SEMICOLON_OP, COLON_OP,

    // ---- Brackets & Parentheses ----
    OPEN_PAREN, CLOSE_PAREN, 
    OPEN_BRACE, CLOSE_BRACE, 
    OPEN_BRACKET, CLOSE_BRACKET
};

/**
 * @struct Token
 * @brief Represents a single lexical unit emitted by the scanner.
 */
struct Token {
    TokenType type;         ///< The categorized type of the token
    std::string lexeme;     ///< The exact string matched in the source code
    int line;               ///< The line number where the token was found
};

// ============================================================================
// Utility Function Declarations
// ============================================================================

/**
 * @brief Converts a TokenType enum back into a human-readable string.
 * @param type The TokenType to convert.
 * @return String representation of the token type.
 */
std::string token_type_to_string(TokenType type);

/**
 * @brief Looks up a string to see if it is a reserved keyword.
 * @param str The identifier text to look up.
 * @return An optional containing the specific TokenType if found, otherwise empty.
 */
std::optional<TokenType> get_keyword_type(const std::string& str);

/**
 * @brief Looks up a punctuation string to determine its operator token.
 * @param str The operator text to look up.
 * @return An optional containing the specific TokenType if found, otherwise empty.
 */
std::optional<TokenType> get_operator_type(const std::string& str);

#endif // TOKEN_HPP
