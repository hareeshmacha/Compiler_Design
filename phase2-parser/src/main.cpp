#include <iostream>
#include <iomanip>
#include <vector>
#include "semantic_types.hpp"

// Flex/Bison interface
extern int yyparse();
extern FILE* yyin;

// Globals used by parser/lexer
std::vector<ParsedToken*> all_tokens;
bool parse_error = false;

int main(int argc, char** argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            std::cerr << "Error: Cannot open file " << argv[1] << "\n";
            return 1;
        }
    }

    // Run the Bison parser (which calls yylex() internally)
    yyparse();

    if (yyin) fclose(yyin);

    // If there was a syntax error, we don't print the token table
    if (parse_error) {
        // Cleanup memory
        for (auto* tok : all_tokens) delete tok;
        return 1;
    }

    // Print the success table!
    std::cout << std::left << std::setw(25) << "Token" << "| Token_Type" << "\n";
    std::cout << std::string(25, '-') << "|" << std::string(15, '-') << "\n";

    for (auto* tok : all_tokens) {
        std::string final_type = tok->semantic_role.empty() ? tok->default_token : tok->semantic_role;
        
        // Print everything except single character punctuation as its literal self, 
        // unless it's a special multi-char op. For simplicity, we just print final_type.
        std::cout << std::left << std::setw(25) << tok->lexeme 
                  << "| " << final_type << "\n";
                  
        delete tok; // cleanup
    }

    return 0;
}
