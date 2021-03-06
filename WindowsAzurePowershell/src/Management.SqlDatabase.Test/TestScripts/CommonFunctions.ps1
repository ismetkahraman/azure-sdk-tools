# ----------------------------------------------------------------------------------
#
# Copyright 2011 Microsoft Corporation
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ----------------------------------------------------------------------------------

# Loads Microsoft.WindowsAzure.Management module
# Selects a subscription id to be used by the test

function Init-TestEnvironment
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [String]
        $SubscriptionID,
        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [String]
        $SerializedCert
    )
    $ConfirmPreference = "Medium"
    $DebugPreference = "Continue"
    $ErrorActionPreference = "Continue"
    $FormatEnumerationLimit = 10000
    $ProgressPreference = "SilentlyContinue"
    $VerbosePreference = "Continue"
    $WarningPreference = "Continue"
    $WhatIfPreference = $false

    $moduleLoaded = Get-Module -Name "Microsoft.WindowsAzure.Management"
    if(!$moduleLoaded)
    {
        Import-Module .\Microsoft.WindowsAzure.Management.SqlDatabase.Test.psd1
    }

    # Deserialize the input certificate given in base 64 format.
    # Install it in the cert store.
    $storeName = [System.Security.Cryptography.X509Certificates.StoreName]
    $storeLocation = [System.Security.Cryptography.X509Certificates.StoreLocation]
    $X509Certificate2 = [System.Security.Cryptography.X509Certificates.X509Certificate2]
    $X509Store = [System.Security.Cryptography.X509Certificates.X509Store]
    $OpenFlags = [System.Security.Cryptography.X509Certificates.OpenFlags]
    
    $bytes = [System.Convert]::FromBase64String($SerializedCert)
    $myCert = New-Object $X509Certificate2(,$bytes)
    $store = New-Object $X509Store($StoreName::My, $StoreLocation::CurrentUser)
    $store.Open($OpenFlags::ReadWrite)
    $store.Add($myCert)
    $store.Close()
    
    $subName = "MySub" + $SubscriptionID
    Set-AzureSubscription -SubscriptionName $subName -SubscriptionId $SubscriptionID -Certificate $myCert
    Select-AzureSubscription -SubscriptionName $subName
}

function Assert 
{
    #.Example
    # set-content C:\test2\Documents\test2 "hi"
    # C:\PS>assert { get-item C:\test2\Documents\test2 } "File wasn't created by Set-Content!"
    #
    [CmdletBinding()]
    param( 
       [Parameter(Position=0,ParameterSetName="Script",Mandatory=$true)]
       [ScriptBlock]$Condition
    ,
       [Parameter(Position=0,ParameterSetName="Bool",Mandatory=$true)]
       [bool]$Success
    ,
       [Parameter(Position=1,Mandatory=$true)]
       [string]$Message
    )

    $message = "ASSERT FAILED: $message"
  
    if($PSCmdlet.ParameterSetName -eq "Script") 
    {
        try 
        {
            $ErrorActionPreference = "STOP"
            $success = &$condition
        } 
        catch 
        {
            $success = $false
            $message = "$message`nEXCEPTION THROWN: $($_.Exception.GetType().FullName)"         
        }
    }
    if(!$success) 
    {
        throw $message
    }
}

function Validate-SqlDatabaseServerOperationContext 
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [Microsoft.WindowsAzure.Management.SqlDatabase.Model.SqlDatabaseServerOperationContext]
        $Actual, 
        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ExpectedServerName,
        [Parameter(Mandatory=$true, Position=2)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ExpectedOperationDescription
    )
    
    $expectedOperationStatus = "Success"
    Assert {$actual} "SqlDatabaseServerOperationContext is null"
    Assert {$actual.ServerName -eq $expectedServerName} "ServerName didn't match. Actual:[$($actual.ServerName)] expected:[$expectedServerName]"
    Assert {$actual.OperationDescription -eq $expectedOperationDescription} "OperationDescription didn't match. Actual:[$($actual.OperationDescription)] expected:[$expectedOperationDescription]"
    Assert {$actual.OperationStatus -eq $expectedOperationStatus} "OperationStatus didn't match. Actual:[$($actual.OperationStatus)] expected:[$expectedOperationStatus]"
}

function Validate-SqlDatabaseServerContext
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [Microsoft.WindowsAzure.Management.SqlDatabase.Model.SqlDatabaseServerContext]
        $Actual,
        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ExpectedAdministratorLogin,
        [Parameter(Mandatory=$true, Position=2)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ExpectedLocation,
        [Parameter(Mandatory=$true, Position=3)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ExpectedServerName,
        [Parameter(Mandatory=$true, Position=4)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ExpectedOperationDescription
    )

    Assert {$actual} "SqlDatabaseServerContext is null"
    Assert {$actual.AdministratorLogin -eq $ExpectedAdministratorLogin} "AdministratorLogin didn't match. Actual:[$($actual.AdministratorLogin)] expected:[$ExpectedAdministratorLogin]"
    Assert {$actual.Location -eq $ExpectedLocation} "Location didn't match. Actual:[$($actual.Location)] expected:[$ExpectedLocation]"
    Validate-SqlDatabaseServerOperationContext -Actual $actual -ExpectedServerName $ExpectedServerName -ExpectedOperationDescription $ExpectedOperationDescription
}

function Validate-SqlDatabaseServerFirewallRuleContext
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [Microsoft.WindowsAzure.Management.SqlDatabase.Model.SqlDatabaseServerFirewallRuleContext]
        $Actual,
        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ExpectedRuleName,
        [Parameter(Mandatory=$true, Position=2)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ExpectedStartIpAddress,
        [Parameter(Mandatory=$true, Position=3)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ExpectedEndIpAddress,
        [Parameter(Mandatory=$true, Position=4)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ExpectedServerName,
        [Parameter(Mandatory=$true, Position=5)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ExpectedOperationDescription
    )

    Assert {$actual} "SqlDatabaseServerContext is null"
    Assert {$actual.RuleName -eq $ExpectedRuleName} "RuleName didn't match. Actual:[$($actual.RuleName)] expected:[$ExpectedRuleName]"
    Assert {$actual.StartIpAddress -eq $ExpectedStartIpAddress} "StartIpAddress didn't match. Actual:[$($actual.StartIpAddress)] expected:[$ExpectedStartIpAddress]"
    Assert {$actual.EndIpAddress -eq $ExpectedEndIpAddress} "EndIpAddress didn't match. Actual:[$($actual.EndIpAddress)] expected:[$ExpectedEndIpAddress]"
    Validate-SqlDatabaseServerOperationContext -Actual $actual -ExpectedServerName $ExpectedServerName -ExpectedOperationDescription $ExpectedOperationDescription
}

function Drop-Server
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [Microsoft.WindowsAzure.Management.SqlDatabase.Model.SqlDatabaseServerOperationContext]
        $Server
    )

    if($server)
    {
        # Drop server
        Write-Output "Dropping server $($server.ServerName) ..."
        Remove-AzureSqlDatabaseServer -ServerName $server.ServerName -Force
        Write-Output "Dropped server $($server.ServerName)"
    }
}

function Write-TestResult
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [bool]
        $TestResult
    )

    if($IsTestPass)
    {
        Write-Output "PASS"
    }
    else
    {
        Write-Output "FAILED"
    }
}
