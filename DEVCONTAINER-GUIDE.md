# DevContainer Quick Guide

This project provides two development container options:

## 🐧 Linux Container (Default)
**Location**: `.devcontainer/`  
**Best for**: General development, CI/CD, cross-platform work

```bash
# Lightweight, fast startup, smaller size (~1GB)
```

## 🪟 Windows Container  
**Location**: `.devcontainer-windows/`  
**Best for**: Windows-specific modules, registry access, Windows APIs

```bash
# Native Windows PowerShell, larger size (~4GB+)
```

## Quick Switch

### Using VS Code Command Palette:
1. `Ctrl+Shift+P` → "Dev Containers: Reopen in Container"
2. Choose your desired configuration file

### Using File Explorer:
1. Rename `.devcontainer-windows` to `.devcontainer` (backup original)
2. Rebuild container

---

**💡 Tip**: Use Linux for daily development, Windows for Windows-specific testing.

See `.devcontainer/README.md` for detailed instructions.
