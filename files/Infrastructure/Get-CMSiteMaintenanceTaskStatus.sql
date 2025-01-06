-- Get Status of Site Maintenance Task by name
-- https://techcommunity.microsoft.com/blog/coreinfrastructureandsecurityblog/mecm-how-site-maintenance-tasks-can-make-your-life-much-easier/2134984

DECLARE @SiteCode NVARCHAR(100) = '001'
DECLARE @TaskName NVARCHAR(100) = 'Delete Aged Discovery Data'

SELECT
	[Sites].[SiteCode],
	[Sites].[SiteName],
	[Sites].[SiteServer],
	[Status].[TaskName],
	[Status].[TaskType],
	[Status].[LastStartTime],
	[Status].[LastCompletionTime],
	[Status].[CompletionStatus],
	[Status].[RunNow]

FROM [SQLTaskSiteStatus] AS [Status]
LEFT JOIN [Sites] ON [Status].[SiteNumber] = [Sites].[SiteKey]
WHERE [Sites].[SiteCode] = @SiteCode AND [Status].[TaskName] = @TaskName


/* Disclaimer 
Sample scripts are not supported under any Microsoft standard support program or service. The sample scripts is 
provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without 
limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk 
arising out of the use or performance of the sample script and documentation remains with you. In no event shall 
Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable 
for any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, 
loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample script 
or documentation, even if Microsoft has been advised of the possibility of such damages.
*/



