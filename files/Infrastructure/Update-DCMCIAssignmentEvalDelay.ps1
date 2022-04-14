# Updates the DCM CI Assignment Evaluation Delay and Launch Condition
$SiteServer             =   'yoursiteserver.fqdn'
$SiteCode               =   'XYZ'

Function Show-Values{
    $PropsObject    = Get-WMIObject -ComputerName $SiteServer -Namespace "root\SMS\Site_$SiteCode" -Class SMS_SCI_ClientComp | Where-Object {$_.FileType -eq 2 -and $_.ItemName -eq 'Software Updates' -and $_.ItemType -eq 'Client Component' -and $_.SiteCode -eq $SiteCode} | Select-Object -ExpandProperty Props 
    $DelaySetting   = $PropsObject | Where-Object PropertyName -eq 'DCM CI Assignment Evaluation Max Random Delay Minutes' | Select-Object -ExpandProperty Value
    $LaunchSetting  = $PropsObject | Where-Object PropertyName -eq 'DCM CI Assignment Evaluation Launch Conditions' | Select-Object -ExpandProperty Value
    Write-Host "[DCM CI Assignment Evaluation Max Random Delay Minutes] is currently set to $DelaySetting" -ForegroundColor Cyan
    Write-Host "[DCM CI Assignment Evaluation Launch Conditions] is currently set to $LaunchSetting" -ForegroundColor Cyan
}

Function Set-Props{
    $ClientComp = (Get-WMIObject -ComputerName $SiteServer -Namespace "root\SMS\Site_$SiteCode" -Class SMS_SCI_ClientComp | Where-Object {$_.FileType -eq 2 -and $_.ItemName -eq 'Software Updates' -and $_.ItemType -eq 'Client Component' -and $_.SiteCode -eq $SiteCode})
    $ClientComp.Get()
    $Props = $ClientComp.Props

    for ($i = 0; $i -lt $Props.Count; $i++){
        if ($Props[$i].PropertyName -eq $args[0]){
            $Props[$i].Value = $args[1]
            break
        }
    }

    $ClientComp.Props = $Props
    $ClientComp.Put()
}

Write-Host '------------------------------------------------------------------' -ForegroundColor Cyan
Write-Host 'This tool will set the random delay for CI Assignment Evaluations to zero.  This remove the evaluation delay and cause all baseline evaluations to trigger exaclty on schedule.' -ForegroundColor Cyan
Write-Host 'Secondarily, it also sets the lauch conditions to not be dependent on client statistics such as IOPS or CPU usage.' -ForegroundColor Cyan
Show-Values
Pause
Set-Props 'DCM CI Assignment Evaluation Max Random Delay Minutes' 0
Set-Props 'DCM CI Assignment Evaluation Launch Conditions' 2
Show-Values
Write-Host '** Note - The settings will not take effect until the SMS_EXECUTIVE service is restarted.' -ForegroundColor Yellow
