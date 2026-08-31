#include "symbol_table.hpp"

SymbolTable g_symTable;

SymbolTable::SymbolTable() {
    // Initialize with global scope
    enterScope();
}

void SymbolTable::enterScope() {
    scopes.push_back(std::unordered_map<std::string, SymbolEntry>());
}

void SymbolTable::exitScope() {
    if (scopes.size() > 1) { // Don't pop global scope
        scopes.pop_back();
    }
}

void SymbolTable::addSymbol(const std::string& name, SymRole role, const std::string& resolvedType) {
    if (scopes.empty()) return;
    SymbolEntry entry = {name, role, resolvedType};
    scopes.back()[name] = entry;
}

void SymbolTable::addTypedef(const std::string& name) {
    typedefs.insert(name);
}

bool SymbolTable::isTypedef(const std::string& name) const {
    return typedefs.find(name) != typedefs.end();
}

bool SymbolTable::lookup(const std::string& name, SymbolEntry& outEntry) const {
    // Traverse scopes from innermost to outermost
    for (auto it = scopes.rbegin(); it != scopes.rend(); ++it) {
        auto found = it->find(name);
        if (found != it->end()) {
            outEntry = found->second;
            return true;
        }
    }
    return false;
}
