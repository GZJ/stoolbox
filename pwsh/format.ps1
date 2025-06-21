<#
.SYNOPSIS
PowerShell code formatter using PSScriptAnalyzer
#>
Install-Module -Name PSScriptAnalyzer
Import-Module -Name PSScriptAnalyzer


$settings = @{
    IncludeRules = @(
        "PSPlaceOpenBrace",
        "PSPlaceCloseBrace",
        "PSUseConsistentWhitespace",
        "PSUseConsistentIndentation",
        "PSAvoidDefaultValueForMandatoryParameter",
        "PSAvoidDefaultValueSwitchParameter",
        "PSAvoidGlobalAliases",
        "PSAvoidGlobalFunctions",
        "PSAvoidGlobalVars",
        "PSAvoidInvokingEmptyMembers",
        "PSAvoidShouldContinueWithoutForce",
        "PSAvoidUsingCmdletAliases",
        "PSAvoidUsingComputerNameHardcoded",
        "PSAvoidUsingConvertToSecureStringWithPlainText",
        "PSAvoidUsingDeprecatedManifestFields",
        "PSAvoidUsingEmptyCatchBlock",
        "PSAvoidUsingInvokeExpression",
        "PSAvoidUsingPlainTextForPassword",
        "PSAvoidUsingPositionalParameters",
        "PSAvoidUsingUserNameAndPassWordParams",
        "PSAvoidUsingWMICmdlet",
        "PSAvoidUsingWriteHost",
        "PSMisleadingBacktick",
        "PSMissingModuleManifestField",
        "PSPossibleIncorrectComparisonWithNull",
        "PSProvideCommentHelp",
        "PSReservedCmdletChar",
        "PSReservedParams",
        "PSShouldProcess",
        "PSUseApprovedVerbs",
        "PSUseBOMForUnicodeEncodedFile",
        "PSUseCmdletCorrectly",
        "PSUseDeclaredVarsMoreThanAssignments",
        "PSUseLiteralInitializerForHashtable",
        "PSUseOutputTypeCorrectly",
        "PSUsePSCredentialType",
        "PSUseShouldProcessForStateChangingFunctions",
        "PSUseSingularNouns",
        "PSUseSupportsShouldProcess",
        "PSUseToExportFieldsInManifest"
    )

    Rules = @{
        PSPlaceOpenBrace = @{
            Enable = $true
            OnSameLine = $true
            NewLineAfter = $true
            IgnoreOneLineBlock = $true
        }
        PSPlaceCloseBrace = @{
            Enable = $true
            NewLineAfter = $true
            IgnoreOneLineBlock = $true
            NoEmptyLineBefore = $false
        }
        PSUseConsistentIndentation = @{
            Enable = $true
            Kind = "space"
            IndentationSize = 4
        }
        PSUseConsistentWhitespace = @{
            Enable = $true
            CheckOpenBrace = $true
            CheckOpenParen = $true
            CheckOperator = $true
            CheckSeparator = $true
        }
        PSAvoidUsingCmdletAliases = @{
            Whitelist = @("%","?","select","sort","group")
        }
        PSProvideCommentHelp = @{
            Enable = $true
            ExportedOnly = $false
            BlockComment = $true
            VSCodeSnippetCorrection = $true
            Placement = "begin"
        }
    }
}

Get-Content "gpaste.ps1" | Invoke-Formatter -Settings $settings
