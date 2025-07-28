# Windows Development Container Configuration

This Windows-based development container provides native Windows PowerShell compatibility for the PSDigitalOcean module.

## Features

- PowerShell 7.x on Windows Server 2022 Core
- Native Windows PowerShell environment
- Access to Windows-only modules and cmdlets
- Registry and Windows API access
- All development tools from the Linux container

## When to Use This Configuration

Use this Windows container when you need:

- Windows-specific PowerShell modules
- Registry operations
- Windows API interactions
- Testing Windows-only scenarios
- Native Windows PowerShell behavior

## Requirements

- Docker Desktop with Windows containers enabled
- Windows 10/11 or Windows Server host
- VS Code with Dev Containers extension

## Setup

1. **Switch Docker Desktop to Windows containers:**
   - Right-click Docker Desktop tray icon
   - Select "Switch to Windows containers..."

2. **Follow the same setup steps as the Linux container:**
   - Set DIGITALOCEAN_TOKEN environment variable
   - Open project in VS Code
   - Select "Dev Containers: Reopen in Container"
   - Choose this configuration when prompted

## Performance Considerations

- **Larger size**: ~4GB+ vs ~1GB for Linux
- **Slower startup**: Windows containers take longer to initialize
- **Resource usage**: Higher memory and CPU usage
- **Host requirements**: Windows container support needed

## Security

⚠️ **Same security considerations apply:**
- Never commit API tokens to version control
- The container inherits environment variables from the host
- Remove or change test tokens before committing

## Switching Back to Linux

To switch back to the Linux container:

1. Switch Docker Desktop back to Linux containers
2. Use VS Code Command Palette: "Dev Containers: Rebuild Container"
3. Select the Linux configuration (`.devcontainer/devcontainer.json`)
