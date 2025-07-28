@{
    # PSScriptAnalyzer settings for PSDigitalOcean module

    # Include all default rules except the ones we want to exclude
    IncludeDefaultRules = $true

    # Exclude rules that conflict with our coding style
    ExcludeRules = @(
        'PSPlaceOpenBrace',      # Don't enforce open brace placement (allows same line)
        'PSPlaceCloseBrace'      # Don't enforce close brace placement
    )

    # Only show Error and Warning severity by default
    Severity = @('Error', 'Warning')
}
