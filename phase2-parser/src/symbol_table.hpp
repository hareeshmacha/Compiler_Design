#ifndef SYMBOL_TABLE_HPP
#define SYMBOL_TABLE_HPP

#include <string>
#include <vector>
#include <unordered_map>
#include <unordered_set>
#include "semantic_types.hpp"

struct SymbolEntry {
    std::string name;
    SymRole role;
    std::string resolved_type_string; // e.g. "INT_POINTER"
};

class SymbolTable {
private:
    std::vector<std::unordered_map<std::string, SymbolEntry>> scopes;
    std::unordered_set<std::string> typedefs; // For the typedef lexer hack

public:
    SymbolTable();
    void enterScope();
    void exitScope();
    void addSymbol(const std::string& name, SymRole role, const std::string& resolvedType);
    void addTypedef(const std::string& name);
    bool isTypedef(const std::string& name) const;
    
    // Returns true if found, stores result in outEntry
    bool lookup(const std::string& name, SymbolEntry& outEntry) const;
};

// Global instance for Bison to use
extern SymbolTable g_symTable;

#endif
