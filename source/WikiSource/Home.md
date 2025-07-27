# PSDigitalOcean Wiki

Welcome to the PSDigitalOcean PowerShell module documentation!

## Overview

PSDigitalOcean is a comprehensive PowerShell module for managing
DigitalOcean resources with enterprise-grade reliability and extensive
test coverage.

### Key Features

- **96.16% Test Coverage** with 205 comprehensive tests
- **Class-based Architecture** with strongly-typed PowerShell classes
- **Complete API Integration** for DigitalOcean services
- **Professional Documentation** with detailed help files
- **Modern Build System** using Sampler framework

## Available Functions

### Public Functions

| Function | Description | Version |
|----------|-------------|---------|
| `Get-DigitalOceanAccount` | Account information with pagination | 1.0.0 |
| `Get-DigitalOceanImage` | DigitalOcean images with filtering | 1.0.0 |
| `Get-DigitalOceanRegion` | DigitalOcean regions | 1.0.0 |
| `Get-DigitalOceanSize` | DigitalOcean Droplet sizes | 1.1.0 |

### PowerShell Classes

| Class | Description | Properties |
|-------|-------------|------------|
| `Account` | Account information | Email, UUID, team, limits |
| `Team` | Team information | Name, UUID |
| `DigitalOceanImage` | Image metadata | ID, name, type, distribution |
| `DigitalOceanRegion` | Region information | Name, slug, features |
| `DigitalOceanSize` | Droplet specifications | Slug, memory, vCPUs, disk |

## Quick Start

1. **Installation**

   ```powershell
   Install-Module -Name PSDigitalOcean -Scope CurrentUser
   ```

1. **Configuration**

   ```powershell
   [Environment]::SetEnvironmentVariable(
       "DIGITALOCEAN_TOKEN",
       "your-api-token-here",
       [System.EnvironmentVariableTarget]::User
   )
   ```

1. **Usage**

   ```powershell
   # Get account information
   Get-DigitalOceanAccount
   
   # Get all available sizes
   Get-DigitalOceanSize -All
   
   # Get Ubuntu images
   Get-DigitalOceanImage -Type distribution -Distribution ubuntu
   
   # Get all regions
   Get-DigitalOceanRegion
   ```

## Navigation

- [[Get-DigitalOceanAccount]] - Account management
- [[Get-DigitalOceanImage]] - Image management  
- [[Get-DigitalOceanRegion]] - Region information
- [[Get-DigitalOceanSize]] - Size specifications and Droplet sizing
- [[API-Integration]] - Core API functionality
- [[PowerShell-Classes]] - Class architecture
- [[Development-Guide]] - Contributing guidelines
