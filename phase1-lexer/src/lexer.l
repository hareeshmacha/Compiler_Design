/**
 * @file lexer.l
 * @brief Flex definitions for the custom C-like Lexical Analyzer.
 *
 * Provides regular expressions and actions to tokenize source code. It includes robust
 * error handling (collecting all errors without crashing) and tracks line/column data.
 */

%option noyywrap
%option yylineno
%option nounput
%option noinput

%{
#include <iostream>
#include <string>
#include <vector>
#include "token_mapper.hpp"
#include "error_handler.hpp"

// Global state referenced by logger.cpp
extern std::vector<Token> tokens;

/**
 * @brief Helper to cleanly push tokens into our global vector.
 * @param type The TokenType enum value.
 * @param lexeme The exact matched string.
 */
static void addToken(TokenType type, const std::string& lexeme) {
    tokens.push_back({type, lexeme, yylineno});
}

// Variables for multi-line literal tracking
static std::string strbuf;
static int tokStartLine;
static bool litHadError;
static int charCount;
%}

/* ========================================================================= */
/* MACROS & DEFINITIONS                                                      */
/* ========================================================================= */

DIGIT       [0-9]
LETTER      [a-zA-Z_]
ID          {LETTER}({LETTER}|{DIGIT})*
HEXDIGIT    [0-9a-fA-F]
OCTDIGIT    [0-7]
BINDIGIT    [01]

/* Integer Suffixes (unsigned, long, long long) */
LSUF        (l|L)
LLSUF       (ll|LL)
USUF        (u|U)
INT_SUFFIX  ({USUF}({LLSUF}|{LSUF})?|({LLSUF}|{LSUF}){USUF}?)

/* Fractional floats */
FRAC        ({DIGIT}+\.{DIGIT}*|\.{DIGIT}+)

/* Custom States for strings, chars, and block comments */
%x STRSTATE
%x CHRSTATE
%x COMMENTSTATE

%%

 /* ========================================================================= */
 /* COMMENTS & WHITESPACE                                                     */
 /* ========================================================================= */

"/*"                             { tokStartLine = yylineno; BEGIN(COMMENTSTATE); }
<COMMENTSTATE>"*/"               { BEGIN(INITIAL); }
<COMMENTSTATE>\n                 { /* yylineno tracks this automatically */ }
<COMMENTSTATE><<EOF>>            { reportError(tokStartLine, "/*", "Unterminated block comment"); BEGIN(INITIAL); yyterminate(); }
<COMMENTSTATE>.                  { /* skip comment body */ }

"//"[^\n]*                       { /* Line comment, skip */ }

[ \t\r]+                         { /* Skip horizontal whitespace */ }
\n                               { /* Skip vertical whitespace */ }

 /* ========================================================================= */
 /* IDENTIFIERS & KEYWORDS                                                    */
 /* ========================================================================= */

{ID}                             {
                                     // Lookup to see if this ID is actually a reserved keyword
                                     auto kw = get_keyword_type(yytext);
                                     if (kw.has_value()) {
                                         addToken(kw.value(), yytext);
                                     } else {
                                         addToken(TokenType::IDENTIFIER, yytext);
                                     }
                                 }

 /* ========================================================================= */
 /* STRING LITERALS                                                           */
 /* ========================================================================= */

\"                               { strbuf = "\""; tokStartLine = yylineno; litHadError = false; BEGIN(STRSTATE); }

<STRSTATE>\\[0-7]{1,3}           { strbuf += yytext; /* Octal escape */ }
<STRSTATE>\\x{HEXDIGIT}+         { strbuf += yytext; /* Hex escape */ }
<STRSTATE>\\[ntr\\'\"abfv?]      { strbuf += yytext; /* Standard escape */ }
<STRSTATE>\\[^\n]                { reportError(yylineno, yytext, "Invalid escape sequence"); litHadError = true; strbuf += yytext; }

<STRSTATE>\"                     { strbuf += "\""; if (!litHadError) addToken(TokenType::STRING_LITERAL, strbuf); BEGIN(INITIAL); }
<STRSTATE>\n                     { reportError(tokStartLine, strbuf, "Unterminated string literal"); BEGIN(INITIAL); }
<STRSTATE><<EOF>>                { reportError(tokStartLine, strbuf, "Unterminated string literal"); BEGIN(INITIAL); yyterminate(); }
<STRSTATE>.                      { strbuf += yytext; }

 /* ========================================================================= */
 /* CHARACTER LITERALS                                                        */
 /* ========================================================================= */

'                                { strbuf = "'"; tokStartLine = yylineno; litHadError = false; charCount = 0; BEGIN(CHRSTATE); }
<CHRSTATE>\\[ntr\\'\"abfv?]      { strbuf += yytext; charCount++; }
<CHRSTATE>\\x{HEXDIGIT}+         { strbuf += yytext; charCount++; }
<CHRSTATE>\\[0-7]{1,3}           { strbuf += yytext; charCount++; }
<CHRSTATE>\\[^\n]                { reportError(yylineno, yytext, "Invalid escape sequence"); litHadError = true; strbuf += yytext; charCount++; }
<CHRSTATE>'                      { 
                                     strbuf += "'"; 
                                     if (charCount > 1) {
                                         reportError(tokStartLine, strbuf, "Multi-character char literal");
                                     } else if (charCount == 0) {
                                         reportError(tokStartLine, strbuf, "Empty char literal");
                                     } else if (!litHadError) {
                                         addToken(TokenType::CHAR_LITERAL, strbuf); 
                                     }
                                     BEGIN(INITIAL); 
                                 }
<CHRSTATE>\n                     { reportError(tokStartLine, strbuf, "Unterminated character literal"); BEGIN(INITIAL); }
<CHRSTATE><<EOF>>                { reportError(tokStartLine, strbuf, "Unterminated character literal"); BEGIN(INITIAL); yyterminate(); }
<CHRSTATE>.                      { strbuf += yytext; charCount++; }

 /* ========================================================================= */
 /* NUMERIC CONSTANTS                                                         */
 /* ========================================================================= */

0[xX]{HEXDIGIT}+{INT_SUFFIX}?    { addToken(TokenType::INT_LITERAL, yytext); }
0[bB]{BINDIGIT}+{INT_SUFFIX}?    { addToken(TokenType::INT_LITERAL, yytext); }
0{OCTDIGIT}+{INT_SUFFIX}?        { addToken(TokenType::INT_LITERAL, yytext); }
{FRAC}([eE][+-]?{DIGIT}+)?[fF]?  { addToken(TokenType::FLOAT_LITERAL, yytext); }
{DIGIT}+[eE][+-]?{DIGIT}+[fF]?   { addToken(TokenType::FLOAT_LITERAL, yytext); }
{DIGIT}+{INT_SUFFIX}?            { addToken(TokenType::INT_LITERAL, yytext); }

 /* ========================================================================= */
 /* MULTI-CHARACTER OPERATORS                                                 */
 /* ========================================================================= */

"..."                            { addToken(TokenType::ELLIPSIS_OP, yytext); }
"::"                             { addToken(TokenType::SCOPE_RES_OP, yytext); }
"->"                             { addToken(TokenType::ARROW_OP, yytext); }
"++"                             { addToken(TokenType::INC_OP, yytext); }
"--"                             { addToken(TokenType::DEC_OP, yytext); }
"<<="                            { addToken(TokenType::LSHIFT_ASSIGN_OP, yytext); }
">>="                            { addToken(TokenType::RSHIFT_ASSIGN_OP, yytext); }
"<<"                             { addToken(TokenType::LSHIFT_OP, yytext); }
">>"                             { addToken(TokenType::RSHIFT_OP, yytext); }
"<="                             { addToken(TokenType::LE_OP, yytext); }
">="                             { addToken(TokenType::GE_OP, yytext); }
"=="                             { addToken(TokenType::EQ_OP, yytext); }
"!="                             { addToken(TokenType::NE_OP, yytext); }
"&&"                             { addToken(TokenType::LOGICAL_AND_OP, yytext); }
"||"                             { addToken(TokenType::LOGICAL_OR_OP, yytext); }
"+="                             { addToken(TokenType::PLUS_ASSIGN_OP, yytext); }
"-="                             { addToken(TokenType::MINUS_ASSIGN_OP, yytext); }
"*="                             { addToken(TokenType::STAR_ASSIGN_OP, yytext); }
"/="                             { addToken(TokenType::DIVIDE_ASSIGN_OP, yytext); }
"%="                             { addToken(TokenType::MOD_ASSIGN_OP, yytext); }
"&="                             { addToken(TokenType::AMP_ASSIGN_OP, yytext); }
"|="                             { addToken(TokenType::PIPE_ASSIGN_OP, yytext); }
"^="                             { addToken(TokenType::CARET_ASSIGN_OP, yytext); }

 /* ========================================================================= */
 /* SINGLE-CHARACTER OPERATORS & PUNCTUATION                                  */
 /* ========================================================================= */

[+\-*/%=<>!&|^~.,?:(){}\[\]\;]   {
                                      // Lookup exact operator token from our map
                                      auto op = get_operator_type(yytext);
                                      if (op.has_value()) {
                                          addToken(op.value(), yytext);
                                      } else {
                                          reportError(yylineno, yytext, "Illegal character");
                                      }
                                 }

 /* ========================================================================= */
 /* FALLBACK ERROR CATCH                                                      */
 /* ========================================================================= */

.                                { reportError(yylineno, yytext, "Illegal character"); }

%%
