<#
.SYNOPSIS
    Deployment validation Pester (BenchPress) tests.
.DESCRIPTION
    This test plan validates all important properties of Azure Files share used in NetApp migration PoC.
.NOTES
    The tests can be run locally in VS Code (extension for Pester is available) or in a workflow.
.EXAMPLE
    Invoke-Pester -Output Detailed scripts/tests/storageAccount.Tests.ps1
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $ResourceGroupName,

    [Parameter(Mandatory)]
    [string]
    $location
)

BeforeAll {
    Import-Module BenchPress.Azure -Force

    $Script:noRgName = 'notestrg'

<#     $Script:rgName = 'rg-test'
    $Script:noRgName = 'notestrg'
    $Script:location = 'westus3' #>
}

Describe 'Verify Resource Group Exists' {
    It "Should contain a Resource Group named $ResourceGroupName - Confirm-AzBPResource" {
        # arrange
        $params = @{
            ResourceType = "ResourceGroup"
            ResourceName = $ResourceGroupName
        }

        # act and assert
        Confirm-AzBPResource @params | Should -BeSuccessful
    }


    It "Should contain a Resource Group named $ResourceGroupName - Confirm-AzBPResource" {
        # arrange
        $params = @{
            ResourceType  = "ResourceGroup"
            ResourceName  = $ResourceGroupName
            PropertyKey   = 'ResourceGroupName'
            PropertyValue = $ResourceGroupName
        }

        # act and assert
        Confirm-AzBPResource @params | Should -BeSuccessful
    }

    It "Should contain a Resource Group named $ResourceGroupName" {
        Confirm-AzBPResourceGroup -ResourceGroupName $ResourceGroupName | Should -BeSuccessful
    }

    It "Should not contain a Resource Group named $noRgName" {
        # The '-ErrorAction SilentlyContinue' command suppresses all errors.
        # In this test, it will suppress the error message when a resource cannot be found.
        # Remove this field to see all errors.
        Confirm-AzBPResourceGroup -ResourceGroupName $noRgName -ErrorAction SilentlyContinue | Should -Not -BeSuccessful
    }

    It "Should contain a Resource Group named $ResourceGroupName in $location" {
        Confirm-AzBPResourceGroup -ResourceGroupName $ResourceGroupName | Should -BeInLocation $location
    }
}

AfterAll {
    Get-Module Az.InfrastructureTesting | Remove-Module
    Get-Module BenchPress.Azure | Remove-Module
}