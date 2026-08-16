// test06_structs_enums.c
enum Color { RED, GREEN, BLUE };

union DataPayload {
    int code;
    float value;
};

typedef struct {
    int x;
    int y;
    enum Color color;
    union DataPayload data;
} Point;

int main() {
    Point p;
    p.x = 10;
    p.color = BLUE;
    p.data.code = 123;
    return 0;
}
