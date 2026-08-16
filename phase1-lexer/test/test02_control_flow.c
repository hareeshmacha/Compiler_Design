// test02_control_flow.c
int main() {
    int i = 0;
    for (i = 0; i < 10; ++i) {
        if (i % 2 == 0) {
            continue;
        } else if (i == 5) {
            break;
        }
    }
    
    int val = 2;
    switch (val) {
        case 1: val++; break;
        case 2: val--; break;
        default: break;
    }
    return val;
}
