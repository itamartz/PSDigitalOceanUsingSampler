# Development Container Configurations

This project provides two different development container configurations to suit different development needs and preferences.

## Available Configurations

### 1. Linux Container (Default) - `.devcontainer/`
- **Base Image**: `mcr.microsoft.com/powershell:lts-debian-11`
- **OS**: Linux (Debian 11)
- **Best For**: 
  - Cross-platform development
  - Smaller container size (~1GB)
  - Faster startup times
  - CI/CD pipelines
  - General PowerShell development

**Advantages:**
- Lightweight and fast
- Cross-platform compatibility
- Better for CI/CD workflows
- Lower resource usage

**Limitations:**
- No Windows-specific modules
- No registry access
- Limited Windows API compatibility

### 2. Windows Container - `.devcontainer-windows/`
- **Base Image**: `mcr.microsoft.com/powershell:lts-windowsservercore-ltsc2022`
- **OS**: Windows Server 2022
- **Best For**:
  - Windows-specific module development
  - Registry operations
  - Windows API interactions
  - Testing Windows-only scenarios

**Advantages:**
- Native Windows PowerShell compatibility
- Access to Windows-only modules
- Registry and Windows API access
- Full Windows cmdlet support

**Limitations:**
- Larger container size (~4GB+)
- Slower startup times
- Requires Windows container support on host

## How to Use Different Configurations

### Method 1: VS Code Command Palette
1. Open Command Palette (`Ctrl+Shift+P` / `Cmd+Shift+P`)
2. Type "Dev Containers: Reopen in Container"
3. When prompted, choose the configuration:
   - Select `.devcontainer/devcontainer.json` for Linux
   - Select `.devcontainer-windows/devcontainer.json` for Windows

### Method 2: Manual Selection
1. Close VS Code
2. Rename the desired configuration folder:
   - For Linux: Keep `.devcontainer/` as is
   - For Windows: Rename `.devcontainer-windows/` to `.devcontainer/` (backup the original first)
3. Reopen VS Code and select "Reopen in Container"

### Method 3: Workspace Settings
Add this to your `.vscode/settings.json` to specify the default:

```json
{
    "dev.containers.defaultPath": ".devcontainer-windows"
}
```

## Prerequisites

- Docker Desktop
- Visual Studio Code with Dev Containers extension
- DigitalOcean API token

## Setup

1. **Set your DigitalOcean API token as an environment variable** on your host machine:

   **Windows (PowerShell):**
   ```powershell
   [Environment]::SetEnvironmentVariable(
       "DIGITALOCEAN_TOKEN",
       "your-api-token-here",
       [System.EnvironmentVariableTarget]::User
   )
   ```

   **macOS/Linux (bash/zsh):**
   ```bash
   export DIGITALOCEAN_TOKEN="your-api-token-here"
   # Add to ~/.bashrc or ~/.zshrc for persistence
   echo 'export DIGITALOCEAN_TOKEN="your-api-token-here"' >> ~/.bashrc
   ```

2. **Open in Dev Container:**
   - Open the project in VS Code
   - Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on macOS)
   - Select "Dev Containers: Reopen in Container"

## Configuration Features

Both configurations include:
- ✅ PowerShell with latest stable version
- ✅ Pester testing framework
- ✅ PSScriptAnalyzer
- ✅ VS Code PowerShell extension
- ✅ GitHub Copilot support
- ✅ Code formatting rules
- ✅ Essential development extensions
- ✅ DigitalOcean API token configuration

## Environment Variables

Both containers set:
- `DIGITALOCEAN_TOKEN`: Your API token for testing (⚠️ **Security Note**: Remove or change before committing)
- `POWERSHELL_UPDATECHECK`: Disabled to prevent update prompts

## Requirements

### For Linux Container
- Docker Desktop with Linux containers enabled
- VS Code with Dev Containers extension

### For Windows Container
- Docker Desktop with Windows containers enabled
- Windows 10/11 or Windows Server host
- VS Code with Dev Containers extension

## Switching Between Configurations

You can easily switch between configurations by:

1. **Using VS Code Command**: `Dev Containers: Rebuild Container`
2. **Changing the folder name**: Rename folders to switch defaults
3. **Using multiple workspaces**: Create separate VS Code workspaces for each configuration

## Troubleshooting

### Windows Container Issues
- Ensure Docker Desktop is set to Windows containers
- Verify Windows container support on your host system
- Check available disk space (Windows containers are larger)

### Linux Container Issues
- Ensure Docker Desktop is set to Linux containers
- Check if WSL2 is properly configured (Windows hosts)

### Performance Tips
- **Linux Container**: Use for most development work
- **Windows Container**: Use only when Windows-specific features are needed
- Consider using Linux for general development and Windows for specific testing scenarios

## Security

⚠️ **Never commit API tokens to version control!**

The devcontainer.json uses `${localEnv:DIGITALOCEAN_TOKEN}` to safely inherit your API token from the host environment without exposing it in the repository.
