// test11_lexical_errors.c
// This file intentionally contains broken syntax
int main() {
    // 1. Multi-character char literal error
    char bad_char = 'XYZ';
    
    // 2. Unterminated string literal
    char* broken = "This string has no closing quote
    
    // 3. Unknown escape sequences
    char* invalid_esc = "Look at this: \q and \z";
    
    // 4. Illegal characters outside string context
    int $money = 100;
    float rate = 5.0 @ 2.0;
    
    return 0;
}
