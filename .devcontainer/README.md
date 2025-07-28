# Dev Container Configuration

This directory contains the development container configuration for the PSDigitalOcean module.

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

## Features

The dev container includes:

- PowerShell 7+ on Debian 11
- Pester testing framework
- PowerShell extensions for VS Code
- Development tools (git, curl, wget)
- Markdown linting
- YAML support
- Spell checker

## Environment Variables

- `DIGITALOCEAN_TOKEN`: Your DigitalOcean API token (inherited from host)
- `POWERSHELL_UPDATECHECK`: Disabled for development environment

## Security

⚠️ **Never commit API tokens to version control!**

The devcontainer.json uses `${localEnv:DIGITALOCEAN_TOKEN}` to safely inherit your API token from the host environment without exposing it in the repository.
