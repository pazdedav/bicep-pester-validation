<#
.SYNOPSIS
    Deployment validation Pester tests.
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
    $subId,

    [Parameter(Mandatory)]
    [string]
    $StorageAccountName
)

Describe -tag "NetApp" -Name "Storage account for NetApp migration PoC" {

    BeforeAll {
        Update-AzConfig -DisplayBreakingChangeWarning $false
        Select-AzSubscription -subscriptionId $subId
    }

    Context "Storage account tests" {

        BeforeAll {
            $storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -ErrorAction SilentlyContinue
        }

        it "Should be provisioned" {
            $storageAccount.ProvisioningState | should -Be 'Succeeded'
        }

        it "Should be GPv2 type" {
            $storageAccount.Kind | should -Be "StorageV2"
        }

        it "Should have max 12 characters in name" {
            $nameLength = $storageAccount.StorageAccountName.Length
            $nameLength | should -BeLessOrEqual 12
        }

        it "Should have disabled public access" {
            $storageAccount.PublicNetworkAccess | should -Be 'Disabled'
        }

        it "Should be joined to AD domain" {
            $storageAccount.AzureFilesIdentityBasedAuth.ActiveDirectoryProperties.DomainName | should -Be "contoso.com"
        }

    <#    it "Should have private endpoint enabled" {
            # Note: this test would fail when executed from a GitHub workflow, unless self-hosted runners are being used.
            $storageAccountHostName = [System.Uri]::new($storageAccount.PrimaryEndpoints.file) | Select-Object -ExpandProperty Host
            $DnsResult = (Resolve-DnsName -Name $storageAccountHostName).IP4Address
            $DnsResult | Should -BeLike "10.44.11.*"
        } #>

    <#     it "Should allow for connection on port TCP/445" {
            # Note: this test would fail when executed from a GitHub workflow, unless self-hosted runners are being used.
            $storageAccountHostName = [System.Uri]::new($storageAccount.PrimaryEndpoints.file) | Select-Object -ExpandProperty Host
            $TestResult = Test-Connection -TargetName $storageAccountHostName -TcpPort 445
            $TestResult | should -Be 'True'
        } #>
    }
}