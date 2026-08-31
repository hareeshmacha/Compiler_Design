// test05_pointers_refs.c
int main() {
    int base = 42;
    int *ptr = &base;
    int **double_ptr = &ptr;
    int ***triple_ptr = &double_ptr;
    
    int &ref = base;
    
    ***triple_ptr = 99;
    return ref;
}
