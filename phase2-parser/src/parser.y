%{
#include <iostream>
#include <vector>
#include <string>
#include "semantic_types.hpp"
#include "symbol_table.hpp"

extern int yylex();
extern int yylineno;
extern char* yytext;
void yyerror(const char* s);

extern std::vector<ParsedToken*> all_tokens;
extern bool parse_error;

void resolveRole(ParsedToken* tok, const std::string& role) {
    if (tok && tok->semantic_role.empty()) {
        tok->semantic_role = role;
    }
}
%}

%union {
    ParsedToken* token_ptr;
    TypeBuilder* type_bld;
}

%token <token_ptr> IDENTIFIER TYPE_NAME
%token <token_ptr> INT CHAR FLOAT DOUBLE VOID SHORT LONG SIGNED UNSIGNED
%token <token_ptr> STRUCT ENUM UNION CLASS
%token <token_ptr> PUBLIC PRIVATE PROTECTED THIS
%token <token_ptr> STATIC TYPEDEF AUTO CONST VOLATILE
%token <token_ptr> IF ELSE FOR WHILE DO UNTIL SWITCH CASE DEFAULT
%token <token_ptr> BREAK CONTINUE GOTO RETURN
%token <token_ptr> PRINTF SCANF MALLOC FREE CALLOC REALLOC
%token <token_ptr> FILE_KW FOPEN FCLOSE FREAD FWRITE FPRINTF FSCANF FGETS FPUTS FEOF
%token <token_ptr> BOOL
%token <token_ptr> NEW DELETE SIZEOF

%token <token_ptr> INT_LITERAL FLOAT_LITERAL CHAR_LITERAL STRING_LITERAL BOOL_LITERAL

%token <token_ptr> ARROW ELLIPSIS SCOPE_RES
%token <token_ptr> INC DEC SHL SHR
%token <token_ptr> LE_OP GE_OP EQ_OP NE_OP AND_OP OR_OP
%token <token_ptr> PLUS_ASSIGN MINUS_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN
%token <token_ptr> AND_ASSIGN OR_ASSIGN XOR_ASSIGN SHL_ASSIGN SHR_ASSIGN

%type <type_bld> type_specifier
%type <type_bld> declaration_specifiers
%type <type_bld> pointer_opt
%type <token_ptr> direct_declarator
%type <token_ptr> declarator

/* Precedence Rules */
%right '=' PLUS_ASSIGN MINUS_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN AND_ASSIGN OR_ASSIGN XOR_ASSIGN SHL_ASSIGN SHR_ASSIGN
%right '?' ':'
%left OR_OP
%left AND_OP
%left '|'
%left '^'
%left '&'
%left EQ_OP NE_OP
%left '<' '>' LE_OP GE_OP
%left SHL SHR
%left '+' '-'
%left '*' '/' '%'
%right UMINUS ADDR DEREF CAST '!' '~' INC DEC
%left '.' ARROW SCOPE_RES '(' '['
%nonassoc IFX
%nonassoc ELSE

%%

program:
      /* empty */
    | program external_decl
    ;

external_decl:
      function_definition
    | declaration
    | error ';' { yyerrok; }
    | error '}' { yyerrok; }
    ;

declaration:
      declaration_specifiers init_declarator_list_opt ';' { delete $1; }
    ;

declaration_specifiers:
      type_specifier { $$ = $1; }
    | declaration_specifiers type_specifier { $$ = $1; }
    | STATIC { $$ = new TypeBuilder(); }
    | CONST { $$ = new TypeBuilder(); }
    | TYPEDEF { $$ = new TypeBuilder(); }
    ;

type_specifier:
      INT { $$ = new TypeBuilder(); $$->base_type = "INT"; }
    | CHAR { $$ = new TypeBuilder(); $$->base_type = "CHAR"; }
    | FLOAT { $$ = new TypeBuilder(); $$->base_type = "FLOAT"; }
    | DOUBLE { $$ = new TypeBuilder(); $$->base_type = "DOUBLE"; }
    | VOID { $$ = new TypeBuilder(); $$->base_type = "VOID"; }
    | BOOL { $$ = new TypeBuilder(); $$->base_type = "BOOL"; }
    | FILE_KW { $$ = new TypeBuilder(); $$->base_type = "FILE"; }
    | TYPE_NAME { 
        $$ = new TypeBuilder(); 
        $$->base_type = "TYPE"; 
        SymbolEntry sym;
        if (g_symTable.lookup($1->lexeme, sym)) resolveRole($1, sym.resolved_type_string);
      }
    | struct_or_class_specifier { $$ = new TypeBuilder(); $$->base_type = "COMPLEX"; }
    ;

struct_or_class_specifier:
      STRUCT IDENTIFIER '{' { resolveRole($2, "STRUCT"); g_symTable.addSymbol($2->lexeme, SymRole::STRUCT_TAG, "STRUCT"); g_symTable.enterScope(); } struct_decl_list '}' { g_symTable.exitScope(); }
    | CLASS IDENTIFIER { resolveRole($2, "CLASS"); g_symTable.addSymbol($2->lexeme, SymRole::CLASS_TAG, "CLASS"); g_symTable.enterScope(); } inheritance_opt '{' struct_decl_list '}' { g_symTable.exitScope(); }
    | ENUM IDENTIFIER '{' { resolveRole($2, "ENUM"); g_symTable.addSymbol($2->lexeme, SymRole::ENUM_TAG, "ENUM"); g_symTable.enterScope(); } struct_decl_list '}' { g_symTable.exitScope(); }
    | STRUCT IDENTIFIER { resolveRole($2, "STRUCT"); }
    | CLASS IDENTIFIER { resolveRole($2, "CLASS"); }
    | ENUM IDENTIFIER { resolveRole($2, "ENUM"); }
    ;

inheritance_opt:
      /* empty */
    | ':' PUBLIC IDENTIFIER
    | ':' PRIVATE IDENTIFIER
    | ':' PROTECTED IDENTIFIER
    | ':' PUBLIC TYPE_NAME
    | ':' PRIVATE TYPE_NAME
    | ':' PROTECTED TYPE_NAME
    ;

struct_decl_list:
      /* empty */
    | struct_decl_list declaration
    | struct_decl_list PUBLIC ':'
    | struct_decl_list PRIVATE ':'
    | struct_decl_list PROTECTED ':'
    | struct_decl_list function_definition
    | struct_decl_list IDENTIFIER '(' parameter_list_opt ')' compound_stmt { resolveRole($2, "CONSTRUCTOR"); }
    | struct_decl_list '~' IDENTIFIER '(' ')' compound_stmt { resolveRole($3, "DESTRUCTOR"); }
    ;

init_declarator_list_opt:
      /* empty */
    | init_declarator_list
    ;

init_declarator_list:
      init_declarator
    | init_declarator_list ',' init_declarator
    ;

init_declarator:
      declarator { resolveRole($1, "VARIABLE"); g_symTable.addSymbol($1->lexeme, SymRole::VARIABLE, "VARIABLE"); }
    | declarator '=' initializer { resolveRole($1, "VARIABLE"); g_symTable.addSymbol($1->lexeme, SymRole::VARIABLE, "VARIABLE"); }
    ;

pointer_opt:
      /* empty */ { $$ = new TypeBuilder(); $$->pointer_depth = 0; }
    | '*' { $$ = new TypeBuilder(); $$->pointer_depth = 1; }
    | '&' { $$ = new TypeBuilder(); $$->pointer_depth = 1; }
    | pointer_opt '*' { $$ = $1; $$->pointer_depth++; }
    | pointer_opt '&' { $$ = $1; $$->pointer_depth++; }
    ;

declarator:
      pointer_opt direct_declarator { $$ = $2; delete $1; }
    ;

direct_declarator:
      IDENTIFIER { $$ = $1; }
    | IDENTIFIER SCOPE_RES IDENTIFIER { $$ = $3; resolveRole($1, "CLASS"); }
    | '(' declarator ')' { $$ = $2; }
    | direct_declarator '[' ']' { $$ = $1; }
    | direct_declarator '[' expr ']' { $$ = $1; }
    | direct_declarator '(' parameter_list_opt ')' { $$ = $1; }
    ;

initializer:
      assignment_expr
    | '{' initializer_list '}'
    | '{' initializer_list ',' '}'
    ;

initializer_list:
      initializer
    | initializer_list ',' initializer
    ;

function_definition:
      declaration_specifiers declarator compound_stmt {
          resolveRole($2, "PROCEDURE");
          g_symTable.addSymbol($2->lexeme, SymRole::PROCEDURE, "PROCEDURE");
          delete $1;
      }
    ;

parameter_list_opt:
      /* empty */
    | parameter_list
    ;

parameter_list:
      parameter_decl
    | parameter_list ',' parameter_decl
    | parameter_list ',' ELLIPSIS
    ;

parameter_decl:
      declaration_specifiers declarator { resolveRole($2, "PARAMETER"); g_symTable.addSymbol($2->lexeme, SymRole::PARAMETER, "PARAMETER"); delete $1; }
    | declaration_specifiers { delete $1; }
    ;

compound_stmt:
      '{' { g_symTable.enterScope(); } block_item_list_opt '}' { g_symTable.exitScope(); }
    ;

block_item_list_opt:
      /* empty */
    | block_item_list
    ;

block_item_list:
      statement
    | block_item_list statement
    ;

statement:
      compound_stmt
    | expr_stmt
    | selection_stmt
    | iteration_stmt
    | jump_stmt
    | declaration
    ;

expr_stmt:
      ';'
    | expr ';'
    ;

selection_stmt:
      IF '(' expr ')' statement %prec IFX
    | IF '(' expr ')' statement ELSE statement
    | SWITCH '(' expr ')' compound_stmt
    | CASE constant_expr ':' statement
    | DEFAULT ':' statement
    ;

iteration_stmt:
      WHILE '(' expr ')' statement
    | DO statement WHILE '(' expr ')' ';'
    | UNTIL '(' expr ')' statement
    | FOR '(' expr_stmt expr_stmt expr_opt ')' statement
    | FOR '(' declaration expr_stmt expr_opt ')' statement
    ;

expr_opt:
      /* empty */
    | expr
    ;

jump_stmt:
      BREAK ';'
    | CONTINUE ';'
    | RETURN ';'
    | RETURN expr ';'
    | GOTO IDENTIFIER ';' { resolveRole($2, "LABEL"); }
    ;

expr:
      assignment_expr
    | expr ',' assignment_expr
    ;

assignment_expr:
      binary_expr
    | unary_expr assign_op assignment_expr
    ;

assign_op:
      '=' | PLUS_ASSIGN | MINUS_ASSIGN | MUL_ASSIGN | DIV_ASSIGN | MOD_ASSIGN
    | AND_ASSIGN | OR_ASSIGN | XOR_ASSIGN | SHL_ASSIGN | SHR_ASSIGN
    ;

constant_expr:
      binary_expr
    ;

binary_expr:
      binary_expr OR_OP binary_expr
    | binary_expr AND_OP binary_expr
    | binary_expr '|' binary_expr
    | binary_expr '^' binary_expr
    | binary_expr '&' binary_expr
    | binary_expr EQ_OP binary_expr
    | binary_expr NE_OP binary_expr
    | binary_expr '<' binary_expr
    | binary_expr '>' binary_expr
    | binary_expr LE_OP binary_expr
    | binary_expr GE_OP binary_expr
    | binary_expr SHL binary_expr
    | binary_expr SHR binary_expr
    | binary_expr '+' binary_expr
    | binary_expr '-' binary_expr
    | binary_expr '*' binary_expr
    | binary_expr '/' binary_expr
    | binary_expr '%' binary_expr
    | binary_expr '?' expr ':' binary_expr
    | unary_expr
    ;

unary_expr:
      postfix_expr
    | INC unary_expr
    | DEC unary_expr
    | '&' unary_expr
    | '*' unary_expr
    | '+' unary_expr
    | '-' unary_expr
    | '!' unary_expr
    | '~' unary_expr
    | '(' type_specifier ')' unary_expr %prec CAST { delete $2; }
    | '(' type_specifier pointer_opt ')' unary_expr %prec CAST { delete $2; delete $3; }
    | SIZEOF unary_expr
    | SIZEOF '(' type_specifier pointer_opt ')' { delete $3; delete $4; }
    | NEW type_specifier { delete $2; }
    | DELETE unary_expr
    | DELETE '[' ']' unary_expr
    ;

postfix_expr:
      primary_expr
    | postfix_expr '[' expr ']'
    | postfix_expr '(' argument_list_opt ')'
    | postfix_expr '.' IDENTIFIER
    | postfix_expr ARROW IDENTIFIER
    | postfix_expr SCOPE_RES IDENTIFIER
    | postfix_expr INC
    | postfix_expr DEC
    | builtin_call
    ;

builtin_call:
      PRINTF '(' argument_list_opt ')'
    | SCANF '(' argument_list_opt ')'
    | MALLOC '(' argument_list_opt ')'
    | FREE '(' argument_list_opt ')'
    | CALLOC '(' argument_list_opt ')'
    | REALLOC '(' argument_list_opt ')'
    | FOPEN '(' argument_list_opt ')'
    | FCLOSE '(' argument_list_opt ')'
    | FREAD '(' argument_list_opt ')'
    | FWRITE '(' argument_list_opt ')'
    | FPRINTF '(' argument_list_opt ')'
    | FSCANF '(' argument_list_opt ')'
    | FGETS '(' argument_list_opt ')'
    | FPUTS '(' argument_list_opt ')'
    | FEOF '(' argument_list_opt ')'
    ;

argument_list_opt:
      /* empty */
    | argument_list
    ;

argument_list:
      assignment_expr
    | argument_list ',' assignment_expr
    ;

primary_expr:
      IDENTIFIER {
          SymbolEntry sym;
          if (g_symTable.lookup($1->lexeme, sym)) {
              resolveRole($1, sym.resolved_type_string);
          }
      }
    | INT_LITERAL
    | FLOAT_LITERAL
    | CHAR_LITERAL
    | STRING_LITERAL
    | BOOL_LITERAL
    | THIS
    | '(' expr ')'
    | lambda_expr
    ;

lambda_expr:
      '[' capture_list_opt ']' '(' { g_symTable.enterScope(); } parameter_list_opt ')' compound_stmt { g_symTable.exitScope(); }
    ;

capture_list_opt:
      /* empty */
    | capture_list
    ;

capture_list:
      IDENTIFIER
    | '&' IDENTIFIER
    | '&'
    | '='
    | capture_list ',' IDENTIFIER
    | capture_list ',' '&' IDENTIFIER
    ;

%%

void yyerror(const char* s) {
    std::cerr << "Syntax error on line " << yylineno << ": " << s << " near '" << yytext << "'\n";
    parse_error = true;
}
