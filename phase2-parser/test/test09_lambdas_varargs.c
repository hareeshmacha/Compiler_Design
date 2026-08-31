// test09_lambdas_varargs.c
void advanced_log(int level, ...) {
    // Variable arguments tested via ellipsis token
}

int main(int argc, char** argv) {
    auto multiplier = [](int base, int factor) -> int {
        return base * factor;
    };
    
    int result = multiplier(5, 10);
    advanced_log(1, result, "success");
    
    return result;
}
