// test07_dynamic_memory.c
int main() {
    int *dynamic_arr = (int*)malloc(10 * sizeof(int));
    
    auto ptr2 = calloc(5, sizeof(float));
    ptr2 = realloc(ptr2, 10 * sizeof(float));
    
    free(dynamic_arr);
    free(ptr2);
    
    return 0;
}
