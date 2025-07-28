@{
    # PSScriptAnalyzer settings file for PSDigitalOcean module

    # Include default rules
    IncludeDefaultRules = $true

    # Exclude specific rules that conflict with project style
    ExcludeRules = @(
        'PSPlaceOpenBrace',           # Allows open braces on same line (try, if, for, etc.)
        'PSPlaceCloseBrace'           # Allows flexible close brace placement
    )

    # Severity levels to include
    Severity = @('Error', 'Warning', 'Information')

    # Custom rule configurations
    Rules = @{
        # Configure PSPlaceOpenBrace rule parameters if needed
        PSPlaceOpenBrace = @{
            Enable = $false
            OnSameLine = $true
            NewLineAfter = $false
            IgnoreOneLineBlock = $true
        }

        # Configure PSPlaceCloseBrace rule parameters if needed
        PSPlaceCloseBrace = @{
            Enable = $false
            NewLineAfter = $false
            IgnoreOneLineBlock = $true
            NoEmptyLineBefore = $false
        }

        # Keep other important formatting rules enabled
        PSUseConsistentIndentation = @{
            Enable = $true
            Kind = 'space'
            PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
            IndentationSize = 4
        }

        PSUseConsistentWhitespace = @{
            Enable = $true
            CheckInnerBrace = $true
            CheckOpenBrace = $false  # Don't enforce whitespace before open brace
            CheckOpenParen = $true
            CheckOperator = $true
            CheckPipe = $true
            CheckPipeForRedundantWhitespace = $false
            CheckSeparator = $true
            CheckParameter = $false
        }

        PSAlignAssignmentStatement = @{
            Enable = $true
            CheckHashtable = $true
        }

        PSUseCorrectCasing = @{
            Enable = $true
        }
    }
}
