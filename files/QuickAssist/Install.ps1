# Install Quick Assist SFB
Add-AppxProvisionedPackage -Online -PackagePath "MicrosoftCorporationII.QuickAssist_2022.825.2016.0_neutral_~_8wekyb3d8bbwe.AppxBundle" -LicensePath "MicrosoftCorporationII.QuickAssist_8wekyb3d8bbwe_4bc27046-84c5-8679-dcc7-d44c77a47dd0.xml"
# Remove Old Type
Remove-WindowsCapability -Online -Name 'App.Support.QuickAssist~~~~0.0.1.0' -ErrorAction 'SilentlyContinue'
