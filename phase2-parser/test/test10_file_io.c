// test10_file_io.c
int main() {
    FILE *fp = fopen("data.txt", "w");
    if (fp != 0) {
        fputs("Hello Compiler\n", fp);
        fprintf(fp, "Status: %d", 200);
        fclose(fp);
    }
    
    FILE *in = fopen("data.txt", "r");
    char buffer[100];
    while (!feof(in)) {
        fgets(buffer, 100, in);
    }
    fclose(in);
    
    return 0;
}
