<#  
.SYNOPSIS  
    A powershell ACP for MEMCM task sequences to download content locally from USB drives.
.DESCRIPTION  
    A powershell ACP for MEMCM task sequences to download content from local drives or UNC paths.
	Note: This script must be called by a the ACP wrapper file LocalACP.cmd
.EXAMPLE
	LocalACP.ps1 X:\Windows\TEMP\SMSTSDownload.INI PS100004 C:\_SMSTaskSquence\Packages\PS100004
.NOTES  
    File Name  : LocalACP.ps1 
    Author     : Curtis Ling
    Requires   : Powershell 5, MEMCM Task Sequence
#>

# Set Variables
$INIFile        = $args[0]
$PackageID      = $args[1]
$TSMDataPath    = $args[2]
$LP             = "D:\LocalPackages"

# Generate Paths
New-Item -Path "$TSMDataPath" -ItemType Directory -Force -Confirm:$False 

# Copy Package
Copy-Item -Path "$LP\$PackageID\*" -Destination "$TSMDataPath" -Recurse -Force -Confirm:$False -Verbose
