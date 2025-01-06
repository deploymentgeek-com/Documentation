<#
.SYNOPSIS
Runs an SCCM Site Maintenance Task (parameterized).  This script should be run in the context of the SCCM Powershell CMDLets.

.DESCRIPTION
Runs an SCCM Site Maintenance Task (parameterized).  This script should be run in the context of the SCCM Powershell CMDLets.

.PARAMETER SiteCode
The SCCM Site Code

.PARAMETER TaskName
The name of the maintenance task to trigger

.NOTES
See https://techcommunity.microsoft.com/blog/coreinfrastructureandsecurityblog/mecm-how-site-maintenance-tasks-can-make-your-life-much-easier/2134984

#>

param(
    [String][Parameter(Mandatory=$True)] $SiteCode,
    [String][Parameter(Mandatory=$True)] $TaskName
)

$Task           = Get-CMSiteMaintenanceTask -SiteCode $SiteCode -Name "$($TaskName)"
$CallMethod     = New-Object 'System.Collections.Generic.Dictionary[String,Object]' 
$CallMethod.Add('SiteCode',$($SiteCode)) 
$CallMethod.Add('TaskName',$($Task.TaskName)) 
$Connection     = Get-CMConnectionManager 
$Connection.ExecuteMethod('SMS_SQLTaskStatus','RunTaskNow',$CallMethod) 


<#
Disclaimer 
Sample scripts are not supported under any Microsoft standard support program or service. The sample scripts is 
provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without 
limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk 
arising out of the use or performance of the sample script and documentation remains with you. In no event shall 
Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable 
for any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, 
loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample script 
or documentation, even if Microsoft has been advised of the possibility of such damages.
#>
