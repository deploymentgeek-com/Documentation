<#
.SYNOPSIS
    Removes a device from multiple collections by the beginning of the collection name and the device name (within a TS)
.DESCRIPTION
    Removes a device from multiple collections by the beginning of the collection name and the device name (within a TS)
.PARAMETER SMSProvider
   SMS Provider server name
.PARAMETER CollectionStartsWith
    Beginning of the name of the collections to remove the device from
.NOTES
    Script name: Remove-DeviceFromCollectionStartsWith-CMAS.ps1
    Author:      Curtis Ling
    DateCreated: 2023-09-29
#>
[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [parameter(Mandatory=$true, HelpMessage="SMS Provider server name")]
    [ValidateNotNullorEmpty()]
    [string]$SMSProvider,
    [parameter(Mandatory=$true, HelpMessage="Starting parts of the Name of the collection to remove device from")]
    [ValidateNotNullorEmpty()]
    [string]$CollectionStartsWith
)

# Create TS Object and populate variables
$TSEnv          = New-Object -COMObject Microsoft.SMS.TSEnvironment
$DeviceName     = ($TSEnv.Value('_SMSTSMachineName'))
$WMIURI         = "https://$SMSProvider/AdminService/wmi"
$LogPath        = ($TSEnv.Value('_SMSTSLogPath'))
$LogFile        = $LogPath + "\RemoveDeviceFromCollectionStartsWith.log"

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
Write-LogFile -Value "CollectionStartsWith: $($CollectionStartsWith)"
Write-LogFile -Value "SMS Provider: $($SMSProvider)"

# Get Collection IDs
$FURI1 = ($WMIURI + '/SMS_Collection?$filter=startswith(Name,' + "'" +  $CollectionStartsWith + "'" + ') eq true')
$CollectionIDs = (Invoke-RestMethod -Method Get -Uri $FURI1 -Credential $SCCMCreds | Select-Object -ExpandProperty value | Select-Object -ExpandProperty CollectionID)


# Get Device Resource IDs
$FURI2 = ($WMIURI + '/SMS_R_System?$filter=Name eq ' + "'" + $DeviceName + "'")
$ResourceIDs = (Invoke-RestMethod -Method Get -Uri $FURI2 -Credential $SCCMCreds | Select-Object -ExpandProperty value | Select-Object -ExpandProperty ResourceID)
Write-LogFile -Value "Resource ID(s): $($ResourceIDs)"

# Process
ForEach($CollectionID in $CollectionIDs){
    Write-LogFile -Value "Collection ID: $($CollectionID)"
    $FURI3 = ($WMIURI + "/SMS_Collection('" + $CollectionID + "')/AdminService.DeleteMembershipRule")
    ForEach ($ResourceID in $ResourceIDs) {
        # Add Device Rule to Collection
            $PostBody = @{
                collectionRule = @{
                    "@odata.type"     = "#AdminService.SMS_CollectionRuleDirect"
                    ResourceClassName = "SMS_R_System"
                    RuleName          = $DeviceName
                    ResourceID        = $ResourceID
                }
            }
            $PostBody = ($PostBody | ConvertTo-Json)
            Write-LogFile -Value "Removing '$($DeviceName)' from Collection '$($CollectionID)"
            Invoke-RestMethod -Method Post -Uri $FURI3 -Credential $SCCMCreds -Body $PostBody -ContentType "application/json"
    }
}
# Stop Logging
Write-LogFile -Value "================== STOP LOGGING =================="
