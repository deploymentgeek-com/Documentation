<#
.SYNOPSIS
    Removes a device direct membership rule from a wildcard collection by the device name (within a TS)
.DESCRIPTION
    Removes a device direct membership rule from a wildcard collection by the device name (within a TS)
.PARAMETER SMSProvider
   SMS Provider server name
.PARAMETER DeviceName
    Name of device name to be removed
.PARAMETER CollectionWildcard
    Name of the collection wildcard to remove device from
.NOTES
    Script name: Remove-ComputerFromCollectionWildcard.ps1
    Author:      Curtis Ling
    DateCreated: 2023-06-16
#>
[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [parameter(Mandatory=$true, HelpMessage="SMS Provider server name")]
    [ValidateNotNullorEmpty()]
    [string]$SMSProvider,
    [parameter(Mandatory=$true, HelpMessage="Name of the collection wildcard to remove device from")]
    [ValidateNotNullorEmpty()]
    [string]$CollectionWildcard
)

# Create TS Object and populate variables
$TSEnv          = New-Object -COMObject Microsoft.SMS.TSEnvironment
$DeviceName     = ($TSEnv.Value('_SMSTSMachineName'))
$LogPath        = ($TSEnv.Value('_SMSTSLogPath'))
$LogFile        = $LogPath + "\RemoveComputerFromCollectionWildcard.log"

# Credentials
$SCCMUser       = ($TSEnv.Value('SCCMUser'))
$PlainPassword  = ($TSEnv.Value('SCCMPassword'))
$SecurePassword = ConvertTo-SecureString -AsPlainText $PlainPassword -Force
$SCCMCreds      = New-Object -Typename System.Management.Automation.PSCredential -Argumentlist $SCCMUser, $SecurePassword

# Functions
Function Write-LogFile {
    param(
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Value
    )
    # Create log file unless it already exists
    if (-not(Test-Path -Path $LogFile -PathType Leaf)) {
        New-Item -Path $LogFile -ItemType File -Force | Out-Null
    }
    # Add timestamp to value
    $Value = (Get-Date).ToShortDateString() + ":" + (Get-Date).ToLongTimeString() + " - " + $Value
    # Add value to log file
    Add-Content -Value $Value -LiteralPath $LogFile -Force
}

# Start Logging
Write-LogFile -Value "================== START LOGGING =================="
Write-LogFile -Value "DeviceName: $($DeviceName)"
Write-LogFile -Value "CollectionWildcard: $($CollectionWildcard)"
Write-LogFile -Value "SMS Provider: $($SMSProvider)"

# Get Site Code
$SiteCode = (Get-WmiObject -Namespace "Root\SMS" -Class SMS_ProviderLocation -ComputerName "$SMSProvider" -Credential $SCCMCreds | Select-Object -ExpandProperty SiteCode)
Write-LogFile -Value "SiteCode: $($SiteCode)"

# Get Collection IDs
$CollectionIDs = (Get-WmiObject -Namespace "Root\SMS\Site_$($SiteCode)" -Class SMS_Collection -ComputerName "$SMSProvider" -Credential $SCCMCreds | Where-Object Name -like "$CollectionWildcard" | Select-Object -ExpandProperty CollectionID)

# Get Device Resource IDs
$ResourceIDs = (Get-WmiObject -Namespace "Root\SMS\Site_$($SiteCode)" -Class SMS_R_System -ComputerName "$SMSProvider" -Credential $SCCMCreds | Where-Object Name -eq "$DeviceName" | Select-Object -ExpandProperty ResourceID)
Write-LogFile -Value "Resource ID(s): $($ResourceIDs)"

# Process
ForEach($CollectionID in $CollectionIDs){
Write-LogFile -Value "Collection ID: $($CollectionID)"
$Collection = (Get-WmiObject -Namespace "Root\SMS\Site_$($SiteCode)" -Class SMS_Collection -ComputerName "$SMSProvider" -Credential $SCCMCreds | Where-Object CollectionID -eq "$CollectionID")
$Collection.Get()

    ForEach ($ResourceID in $ResourceIDs) {
        ForEach ($CollectionRule in $Collection.CollectionRules) {
            # Remove Device Rule from Collection
            If ($CollectionRule.ResourceID -like $ResourceID) {
                Write-LogFile -Value "Removing '$($DeviceName)' from '$($Collection.Name)"
                $Collection.DeleteMembershipRule($CollectionRule)
                }
        }
    }
}
# Stop Logging
Write-LogFile -Value "================== STOP LOGGING =================="
