// test04_arrays_multi.c
int main() {
    int single_arr[5] = {1, 2, 3, 4, 5};
    int multi_arr[3][4] = {
        {1, 2, 3, 4},
        {5, 6, 7, 8},
        {9, 10, 11, 12}
    };
    
    int val = multi_arr[2][1];
    return val;
}
