$servers = Get-Content C:\Scripts\servers.txt

foreach ($server in $servers) {
    Invoke-Command -ComputerName $server -ScriptBlock {#(Get-ScheduledTask -TaskName '*windows*').state
$global:ServerName = [System.Net.Dns]::GetHostName()
Write-Host -Object "Vaidating on " -ForegroundColor yellow -Nonewline
Write-Host -Object "$ServerName" -ForegroundColor green
function CheckTasksStatus{
Write-Output "Tasks $TasksName Found in $TasksState State on $ServerName, It's been Disabled now. Please review the status."
Write-Output "`nTasks Status Before"
Get-ScheduledTask -TaskName '*WindowsPatch*'
Disable-ScheduledTask -TaskName $TasksName | Out-Null
Write-Output "`n*********************************************************"
Write-Output "Tasks Status After"
Get-ScheduledTask -TaskName '*WindowsPatch*' 
}


$TasksState=''
$global:TasksState = (Get-ScheduledTask -TaskName '*WindowsPatch*').state
$global:TasksName = (Get-ScheduledTask -TaskName '*WindowsPatch*').TaskName
if (($TasksState = "Disabled") -or ($TasksState -ne $null)){
Write-Host -Object "    Couldn't find any Task in Enable State for string WindowsPatch."
}
elseif(($TasksState -ne "Disabled") -and ($TasksState -ne $null)){
CheckTasksStatus
$Subject = "WindowsPatch Tasks Status on $ServerName"
$domain = (Get-WmiObject Win32_ComputerSystem).Domain
switch ($domain) {
    { ((Get-WmiObject Win32_ComputerSystem).Domain -eq "admin.domain.com") } { [string]$global:SmtpServer = 'smtplb.domain.com' }
    { ((Get-WmiObject Win32_ComputerSystem).Domain -eq "admin.com") } { [string]$global:SmtpServer = 'mail.admin.com' }
    { ((Get-WmiObject Win32_ComputerSystem).Domain -eq "cerncd.com") } { [string]$global:SmtpServer = 'mail.admin.com' }
    { ((Get-WmiObject Win32_ComputerSystem).Domain -eq "cernc2.com") } { [string]$global:SmtpServer = 'mail.admin.com' }
    { ((Get-WmiObject Win32_ComputerSystem).Domain -eq "cernau.com") } { [string]$global:SmtpServer = 'mail.admin.com' }
    { ((Get-WmiObject Win32_ComputerSystem).Domain -eq "cernse.com") } { [string]$global:SmtpServer = 'mail.admin.com' }
    { ((Get-WmiObject Win32_ComputerSystem).Domain -eq "cernuk.com") } { [string]$global:SmtpServer = 'mail.admin.com' }
    { ((Get-WmiObject Win32_ComputerSystem).Domain -eq "domain.com") } { [string]$global:SmtpServer = 'smtplb.domain.com' }
}
$output = CheckTasksStatus | Out-String
Send-MailMessage -From 'SqlServer@domain.com' -To 'sumit.kumar2@domain.com','admin@domain.com' -Subject $Subject -body $output -Priority High -SmtpServer $SmtpServer
} }
}
