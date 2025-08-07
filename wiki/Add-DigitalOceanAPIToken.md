# Add-DigitalOceanAPIToken

Securely stores your DigitalOcean API token as an environment variable with cross-platform compatibility.

## Synopsis

```powershell
Add-DigitalOceanAPIToken [-Token] <String> [<CommonParameters>]
```

## Description

The `Add-DigitalOceanAPIToken` function provides a secure and convenient way to store your DigitalOcean API token as an environment variable. The function automatically detects your operating system and uses the appropriate storage scope:

- **Windows**: Stores the token in User scope for persistence across sessions
- **Linux/macOS**: Stores the token in Process scope for the current session only

This function is essential for setting up the PSDigitalOcean module before using any other functions that interact with the DigitalOcean API.

## Parameters

### -Token

Specifies the DigitalOcean API token to store.

```
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

## Inputs

### System.String

You can pipe a string containing the API token to this function.

## Outputs

### None

This function does not return any output. It sets the environment variable and provides verbose feedback about the operation.

## Examples

### Example 1: Set API token using parameter

```powershell
Add-DigitalOceanAPIToken -Token "dop_v1_abcd1234567890efgh"
```

This example sets the DigitalOcean API token using the `-Token` parameter.

### Example 2: Set API token using pipeline input

```powershell
"dop_v1_abcd1234567890efgh" | Add-DigitalOceanAPIToken
```

This example demonstrates how to pass the token through the pipeline.

### Example 3: Set API token with verbose output

```powershell
Add-DigitalOceanAPIToken -Token "dop_v1_abcd1234567890efgh" -Verbose
```

This example shows how to use the `-Verbose` parameter to see detailed information about the operation.

### Example 4: Set multiple tokens from an array (last one wins)

```powershell
$tokens = @("token1", "token2", "token3")
$tokens | Add-DigitalOceanAPIToken
```

This example demonstrates pipeline processing with multiple tokens. The last token in the array will be the final value stored.

## Notes

### Platform-Specific Behavior

- **Windows**: The token is stored using `[System.EnvironmentVariableTarget]::User` scope, making it persistent across PowerShell sessions and system restarts.

- **Linux/macOS**: The token is stored using `[System.EnvironmentVariableTarget]::Process` scope for the current session only. A warning message is displayed with instructions for making the token persistent.

### Security Considerations

- The token is stored in plain text as an environment variable
- On Windows, the token persists in the user's environment variables
- On Linux/macOS, the token is only available for the current session
- Ensure your PowerShell session and system are secure when using this function

### Cross-Platform Compatibility

This function is designed to work seamlessly across:
- Windows PowerShell 5.1
- PowerShell 7+ on Windows
- PowerShell 7+ on Linux
- PowerShell 7+ on macOS

## Related Links

- [Get-DigitalOceanAccount](Get-DigitalOceanAccount)
- [Configuration Guide](Configuration)
- [DigitalOcean API Documentation](https://docs.digitalocean.com/reference/api/)

## Troubleshooting

### Common Issues

**Issue**: "Parameter validation failed" error
**Solution**: Ensure the token is not null or empty string

**Issue**: Token not persisting on Linux/macOS
**Solution**: This is expected behavior. Add the token to your shell profile for persistence:
```bash
export DIGITALOCEAN_TOKEN="your-token-here"
```

**Issue**: Permission denied when setting environment variable
**Solution**: Ensure you have appropriate permissions. On Windows, you might need to run PowerShell as Administrator for Machine-scope variables.

### Verification

To verify the token was set correctly:

```powershell
# Check if the token is set
[Environment]::GetEnvironmentVariable("DIGITALOCEAN_TOKEN", [System.EnvironmentVariableTarget]::User)

# Test with a simple API call
Get-DigitalOceanAccount
```

## Version History

- **v1.2.0**: Enhanced class-based architecture with DigitalOceanDroplet support
- **v1.1.0**: Initial implementation with cross-platform support
- Added comprehensive parameter validation
- Added verbose output for troubleshooting
- Added pipeline input support

---

> **Tip**: Always keep your API tokens secure and never commit them to version control systems.
