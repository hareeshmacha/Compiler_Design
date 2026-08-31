// test03_until_loop.c
// Custom keyword implementation
int main() {
    int count = 10;
    
    // until loop executes while the condition is FALSE
    until (count == 0) {
        count--;
    }
    return count;
}
