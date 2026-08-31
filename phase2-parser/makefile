CXX = g++
CXXFLAGS = -Wall -std=c++17 -Isrc

SRC_DIR = src
OBJ_DIR = obj

# Find all C++ files except lex.yy.cpp and parser.tab.cpp (which we generate)
SRCS = $(filter-out $(SRC_DIR)/lex.yy.cpp $(SRC_DIR)/parser.tab.cpp, $(wildcard $(SRC_DIR)/*.cpp))
OBJS = $(patsubst $(SRC_DIR)/%.cpp, $(OBJ_DIR)/%.o, $(SRCS))

TARGET = syntax_analyzer

all: $(TARGET)

# Bison generates parser.tab.cpp and parser.tab.hpp
$(SRC_DIR)/parser.tab.cpp $(SRC_DIR)/parser.tab.hpp: $(SRC_DIR)/parser.y
	bison -d -o $(SRC_DIR)/parser.tab.cpp $(SRC_DIR)/parser.y

# Flex generates lex.yy.cpp, depends on parser.tab.hpp
$(SRC_DIR)/lex.yy.cpp: $(SRC_DIR)/lexer.l $(SRC_DIR)/parser.tab.hpp
	flex -o $(SRC_DIR)/lex.yy.cpp $(SRC_DIR)/lexer.l

# Compile generated Bison file
$(OBJ_DIR)/parser.tab.o: $(SRC_DIR)/parser.tab.cpp | $(OBJ_DIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Compile generated Flex file
$(OBJ_DIR)/lex.yy.o: $(SRC_DIR)/lex.yy.cpp | $(OBJ_DIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Compile other C++ files
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp | $(OBJ_DIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

$(TARGET): $(OBJ_DIR)/parser.tab.o $(OBJ_DIR)/lex.yy.o $(OBJS)
	$(CXX) $(CXXFLAGS) $^ -o $@

clean:
	rm -rf $(OBJ_DIR) $(SRC_DIR)/lex.yy.cpp $(SRC_DIR)/parser.tab.cpp $(SRC_DIR)/parser.tab.hpp $(TARGET)

.PHONY: all clean
