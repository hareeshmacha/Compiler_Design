// test08_classes_oop.c
class Engine {
private:
    int horsepower;
protected:
    float temperature;
public:
    void start() {
        this->temperature = 95.5f;
    }
};

class Car : public Engine {
public:
    void drive() {
        this->start();
    }
};

int main() {
    Car myCar;
    myCar.drive();
    return 0;
}
