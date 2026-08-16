CXX = g++
CXXFLAGS = -std=c++17 -Wall -Wextra
LEX = flex
LFLAGS =

SRC_DIR = src
OBJ_DIR = obj

SOURCES = $(SRC_DIR)/main.cpp $(SRC_DIR)/error_handler.cpp $(SRC_DIR)/token_mapper.cpp
OBJECTS = $(patsubst $(SRC_DIR)/%.cpp, $(OBJ_DIR)/%.o, $(SOURCES))
LEX_SRC = $(SRC_DIR)/lexer.l
LEX_CPP = $(SRC_DIR)/lex.yy.cpp
LEX_OBJ = $(OBJ_DIR)/lex.yy.o

TARGET = lexer

all: $(TARGET)

$(TARGET): $(OBJECTS) $(LEX_OBJ)
	$(CXX) $(CXXFLAGS) -o $@ $^

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp | $(OBJ_DIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(LEX_OBJ): $(LEX_CPP) | $(OBJ_DIR)
	$(CXX) $(CXXFLAGS) -Wno-sign-compare -c $< -o $@

$(LEX_CPP): $(LEX_SRC)
	$(LEX) $(LFLAGS) -o $@ $<

$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

clean:
	rm -rf $(OBJ_DIR) $(LEX_CPP) $(TARGET)

.PHONY: all clean
