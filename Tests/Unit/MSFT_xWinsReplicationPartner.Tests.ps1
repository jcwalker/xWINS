<#
.Synopsis
   Template for creating DSC Resource Unit Tests
.DESCRIPTION
   To Use:
     1. Copy to \Tests\Unit\ folder and rename <ResourceName>.tests.ps1 (e.g. MSFT_xFirewall.tests.ps1)
     2. Customize TODO sections.

.NOTES
   Code in HEADER and FOOTER regions are standard and may be moved into DSCResource.Tools in
   Future and therefore should not be altered if possible.
#>

$script:DSCModuleName   = 'xWINS'
$script:DSCResourceName = 'MSFT_xWinsReplicationPartner'

#region HEADER

# Unit Test Template Version: 1.1.0
[String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Unit 

#endregion HEADER

# Begin Testing
try
{
    #region Pester Test Initialization
    InModuleScope $script:DSCResourceName {
        $mockGetPartner = @{
            ServerIP = '10.0.0.4'
            Partner  = '10.0.0.5'
            Type     = 'PushPull'
        }

        $mockGetTarget = @{
            Partner = '10.0.0.5'
            Ensure    = 'Absent'
        }

        $testParameters = @{
            Partner = '10.0.0.5'
            Type    = 'PushPull'
            Ensure  = 'Present'
        }

        $mockGetTarget4Set = @{
            Partner = '10.0.0.5'
            Type    = 'PushPull'
            Ensure  = 'Present'
        }
        #endregion Pester Test Initialization

        #region Example state 1
        Describe 'The system is not in the desired state' {
            #TODO: Mock cmdlets here that represent the system not being in the desired state
            Mock Get-WinsReplicationPartner -MockWith { @{Type=$null} }
            
            It 'Get method returns Absent' {
                (Get-TargetResource @testParameters).Ensure | Should Be 'Absent'
            }

            It 'Test method returns false when expecting Present' {
                Mock Get-TargetResource -MockWith {$mockGetTarget}
                Test-TargetResource @testParameters | Should be $false
            }

            It 'Test method returns false when Type not in desired state' {
                $mockGetTarget = $mockGetTarget.Clone()
                $mockGetTarget = $mockGetTarget.Add('Type','Push')
                Mock Get-TargetResource @testParameters -MockWith {$mockGetTarget}
                Test-TargetResource @testParameters | Should be $false
            }

            It 'Test method returns false when Enusre not in desired state' {
                Mock Get-TargetResource @testParameters -MockWith {$mockGetTarget}
                Test-TargetResource @testParameters | Should be $false
            }            

            It 'Set method calls Add when Ensure is Present' {
                Mock Get-TargetResource -MockWith {$mockGetPartner}
                Mock Add-WinsReplicationPartner -MockWith {}
                Set-TargetResource @testParameters

                Assert-MockCalled Add-WinsReplicationPartner -Times 1 -Scope It 
            }

            It 'Set method calls Remove when Ensure is Absent' {
                Mock Get-TargetResource -MockWith {$mockGetPartner}
                Mock Remove-WinsReplicationPartner -MockWith {}
                Set-TargetResource -Partner 10.0.0.5 -Type Push -Ensure Absent

                Assert-MockCalled Remove-WinsReplicationPartner -Times 1 -Scope It
            }

            It 'Set method calls Remove and Add when Type not in desired state' {
                Mock Get-TargetResource -MockWith {$mockGetTarget4Set}
                Mock Remove-WinsReplicationPartner -MockWith {}
                Mock Add-WinsReplicationPartner -MockWith {}
                Set-TargetResource -Partner 10.0.0.5 -Type pull -Ensure Present

                Assert-MockCalled Remove-WinsReplicationPartner -Times 1 -Scope It
                Assert-MockCalled Add-WinsReplicationPartner    -Times 1 -Scope It
            }
        }
        #endregion Example state 1

        #region Example state 2
        Describe 'The system is in the desired state' {
            $MockGetTarget = $mockGetTarget4Set.Clone()
            It 'Get method returns Ensure is Present' {
                Mock Get-WinsReplicationPartner -MockWith { @{Type='Push'} }
                (Get-TargetResource @testParameters).Ensure | Should Be 'Present'
            }

            It 'Test method returns true' {
                Mock Get-TargetResource -MockWith {$MockGetTarget}
                Test-TargetResource @testParameters | Should be $true
            }
        }
    }
    #endregion Example state 1

    #region Non-Exported Function Unit Tests

    Describe 'Helper function tests' {            
        Import-Module "$PSScriptRoot\..\..\DSCResources\Library\Helper.psm1"
        $mockNetsh = @(
                'WIns Server 10.0.0.15 add partner server=10.0.0.5 type=0'
                'WIns Server 10.0.0.15 add partner server=10.0.0.5 type=1'
        )

        $partner = '10.0.0.5' 
                
        It 'Get method Type should equal PushPull' { 
            Mock Invoke-Netsh {$mockNetsh} -ModuleName Helper
            (Get-WinsReplicationPartner -Partner $partner).Type | Should be 'PushPull'
        }
        It 'Get method Type should equal Pull' {
            Mock Invoke-Netsh {$mockNetsh[0]} -ModuleName Helper
            (Get-WinsReplicationPartner -Partner $partner).Type | Should be 'Pull'
        }
        It 'Get method Type should equal Push' {
            Mock Invoke-Netsh {$mockNetsh[-1]} -ModuleName Helper
            (Get-WinsReplicationPartner -Partner $partner).Type | Should be 'Push'                                
        }
        It 'Remove method should call Invoke-Netsh without type' {
            Mock Invoke-Netsh {$mockNetsh} -ModuleName Helper
            Remove-WinsReplicationPartner -Partner $partner
            Assert-MockCalled -CommandName Invoke-Netsh -Times 1 -ModuleName Helper -Scope It -ParameterFilter {$ArgumentList -notmatch "type"}                
        }
        It 'Remove method should call Invoke-Netsh with type' {
            Mock Invoke-Netsh {$mockNetsh} -ModuleName Helper
            Remove-WinsReplicationPartner -Partner $partner -Type Push
            Assert-MockCalled -CommandName Invoke-Netsh -Times 1 -ModuleName Helper -Scope It -ParameterFilter {$ArgumentList -match "type"}                
        }
        It 'Add method should call Invoke-Netsh' {
            Add-WinsReplicationPartner -Partner $partner -Type 0
            Assert-MockCalled -CommandName Invoke-Netsh -Times 1 -ModuleName Helper -Scope It
        }  
    }
    #endregion Non-Exported Function Unit Tests
}
finally
{
    #region FOOTER

    Restore-TestEnvironment -TestEnvironment $TestEnvironment

    #endregion
}
