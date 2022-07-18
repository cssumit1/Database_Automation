$global:ServerName = [System.Net.Dns]::GetHostName()

function ZabbixStatusCheck {
    if((Get-Service "Zabbix Agent" -ea SilentlyContinue).Status -ne "Running"){ 
     $services = "Zabbix Agent"
        $maxRepeat = 0
        $status = "Running" # change to Stopped if you want to wait for services to start
        do {
            $count = (Get-Service -ComputerName $ServerName $services | ? { $_.status -eq $status }).count
            $maxRepeat--
        } until ($count -eq 0 -or $maxRepeat -eq 0)
        if((Get-Service "Zabbix Agent" -ea SilentlyContinue).Status -ne "Running"){
        #---------------------------------------
        #Checking Zabbix Service Status:
        #---------------------------------------
        Write-Output "`n*********************************************************"
        Write-Output "`Unable to Start Zabbix Agent, Please review the Agent Status on $ServerName and try to start it manaully!"
        Write-Output "`*********************************************************"
        #Write-Output "`Zabbix Service Status on $ServerName."     
        Get-Service $services -ComputerName $ServerName
        }
}
else {}
}
Function ServerRebootCheck {
    #do while
    #---------------------------------------
    #Checking Last 5 Reboot on the Server
    #---------------------------------------
    $OS = Get-WmiObject Win32_OperatingSystem -ComputerName $ServerName -ErrorAction Stop
    $Uptime = (Get-Date) - $OS.ConvertToDateTime($OS.LastBootUpTime)
    if (($Uptime.Days -eq 0) -and ($Uptime.hours -eq 0) -and ($Uptime.Minutes -lt 60)) {
        # Validating the Crash event id with reasons
        #CrashEventOne
        $global:CrashEventOne = Get-WinEvent -ComputerName $ServerName -FilterHashtable @{logname = 'System'; id = 1074 } -MaxEvents 1 -ErrorAction SilentlyContinue
        #CrashEventTwo
        $filter = @{
            LogName = 'System'
            id      = 1001
            Level   = 2
        }
        $global:CrashEventTwo = Get-WinEvent -ComputerName $ServerName -FilterHashtable $filter -MaxEvents 1 -ErrorAction SilentlyContinue
        #CrashEventThree
        $global:CrashEventThree = Get-WinEvent -ComputerName $ServerName -FilterHashtable @{logname = 'System'; id = 41 } -MaxEvents 1 -ErrorAction SilentlyContinue
        if (($CrashEventOne.Count -gt 0 -or $null -ne $CrashEventOne) -and (Get-Date $CrashEventOne.TimeCreated) -gt ((Get-Date).AddHours(-1))) {
            $global:CrashCase = '1'
            Write-Output "$ServerName has just been restarted."
            #-or ((Get-Date $CrashEventThree.TimeCreated) -lt (Get-Date $CrashEventThree.TimeCreated))) {
            try {
                #---------------------------------------
                #Checking for Reboot Issues
                #---------------------------------------
                Write-Output "`n*********************************************************"
                Write-Output "`Please review the recent reboots Logs on Server $ServerName."
                Write-Output "`*********************************************************" 
                Get-WinEvent -ComputerName $ServerName -FilterHashtable @{logname = 'System'; id = 1074 } -MaxEvents 1 | Format-List 
            }
            catch {
                Write-Output "`Last Reboot Logs not Found for Server $ServerName."
            }
        }
        
        elseif (($CrashEventTwo.Count -gt 0 -or $null -ne $CrashEventTwo) -and (Get-Date $CrashEventTwo.TimeCreated) -gt ((Get-Date).AddHours(-1))) {
            $global:CrashCase = '2'
            Write-Output "$ServerName has just been restarted."
            # if (((Get-Date $CrashEventTwo.TimeCreated) -lt (Get-Date $CrashEventOne.TimeCreated)) -or ((Get-Date $CrashEventTwo.TimeCreated) -lt (Get-Date $CrashEventThree.TimeCreated))) {
            #Checking for Bugcheck Issues
            #---------------------------------------
            $filter = @{
                LogName = 'System'
                id      = 1001
                Level   = 2
            }
            $CrashEventTwo = Get-WinEvent -ComputerName $ServerName -FilterHashtable $filter -MaxEvents 3 -ErrorAction SilentlyContinue
    
            if ($CrashEventTwo.Count -gt 0 -or $null -ne $CrashEventTwo) {
                Write-Output "`n*********************************************************"
                Write-Output "$ServerName has rebooted from a bugcheck error."
                Write-Output "`Please inform System Owner or DBA_ONCALL to review these System crash logs."
                Write-Output "`*********************************************************"
                $CrashEventTwo | Format-List
            }
            else {
                Write-Output "`No Bugcheck Found for Server $ServerName."
            }
        }

        elseif (($CrashEventThree.Count -gt 0 -or $null -ne $CrashEventThree) -and (Get-Date $CrashEventThree.TimeCreated) -gt ((Get-Date).AddHours(-1))) {
            $global:CrashCase = '3'
            Write-Output "$ServerName has just been restarted."
            #if (((Get-Date $CrashEventThree.TimeCreated) -lt (Get-Date $CrashEventOne.TimeCreated)) -or ((Get-Date $CrashEventThree.TimeCreated) -lt (Get-Date $CrashEventTwo.TimeCreated))) {
            try {
                #---------------------------------------
                #Checking for Reboot Issues
                #---------------------------------------
                Write-Output "`n*********************************************************"
                Write-Output "` $ServerName was restarted unexpectedly with below log message."
                Write-Output "`Please inform System Owner or DBA_ONCALL to review these System crash logs."
                Write-Output "`*********************************************************" 
                Get-WinEvent -ComputerName $ServerName -FilterHashtable @{logname = 'System'; id = 41 } -MaxEvents 3 | Format-List
            }
            catch {
                Write-Output "`Last Reboot Logs not Found for Server $ServerName."
            }
        }
    
        #Else if the server is not rebooted in last 60 minutes    
        else {
            Write-Output "`Last Reboot Logs not Found for Server $ServerName."
            Write-Output "`n*********************************************************"
            Write-Output "`We got Server Reboot Alert Triggered from Zabbix for $ServerName, but couldn't find Server restart/crash logs in last one hour. Please review server event viewer logs manaully."
            Write-Output "`*********************************************************" 
            #Checking Last Reboot Time on Server
            Write-Output "`n*********************************************************"
            Write-Output "`Please review the Last Reboot Time on Server $ServerName."
            Write-Output "`*********************************************************"
            Try {
                Write-Output "`Uptime and Last Reboot Status for $ServerName."
                $OS = Get-WmiObject Win32_OperatingSystem -ComputerName $ServerName -ErrorAction Stop
                $Uptime = (Get-Date) - $OS.ConvertToDateTime($OS.LastBootUpTime)
                [PSCustomObject]@{
                    ComputerName = $ServerName
                    LastBoot     = $OS.ConvertToDateTime($OS.LastBootUpTime)
                    Uptime       = ([String]$Uptime.Days + " Days " + $Uptime.Hours + " Hours " + $Uptime.Minutes + " Minutes")
                }
    
            }
            catch {
                [PSCustomObject]@{
                    ComputerName = $ServerName
                    LastBoot     = "Unable to Connect"
                    Uptime       = $_.Exception.Message.Split('.')[0]
                }
            }
        }
    }
    #Else if the server is not rebooted in last 60 minutes   
    else {
        Write-Output "`Last Reboot Logs not Found for Server $ServerName."
        Write-Output "`nWe got Server Reboot Alert Triggered from Zabbix for $ServerName but couldn't find Server restart/crash logs in last one hour, please review Windows Event viewer logs or if theres any zabbix connectivity issues."  
        #Checking Last Reboot Time on Server
        Write-Output "`*********************************************************"
        Write-Output "`Please review the Last Reboot Time on Server $ServerName."
        Write-Output "`*********************************************************"

        Try {
            Write-Output "`Uptime and Last Reboot Status for $ServerName."
            $OS = Get-WmiObject Win32_OperatingSystem -ComputerName $ServerName -ErrorAction Stop
            $Uptime = (Get-Date) - $OS.ConvertToDateTime($OS.LastBootUpTime)
            [PSCustomObject]@{
                ComputerName = $ServerName
                LastBoot     = $OS.ConvertToDateTime($OS.LastBootUpTime)
                Uptime       = ([String]$Uptime.Days + " Days " + $Uptime.Hours + " Hours " + $Uptime.Minutes + " Minutes")
            }
    
        }
        catch {
            [PSCustomObject]@{
                ComputerName = $ServerName
                LastBoot     = "Unable to Connect"
                Uptime       = $_.Exception.Message.Split('.')[0]
            }
        }
    }
    ZabbixStatusCheck # Function to check Zabbix Status
}
ServerRebootCheck 
$output = ServerRebootCheck | Out-String

#$output = "<H2>Find The Following Details</H2>" + $output

#$output = [System.IO.File]::ReadAllText("C:\Logs\serverstatus.html")
#$body = Get-Content -Path C:\SvcPaks\logs5.txt
$Subject = "Server $ServerName HealthCheck Status"
    
$domain = (Get-WmiObject Win32_ComputerSystem).Domain
switch ($domain) {
    { ((Get-WmiObject Win32_ComputerSystem).Domain -eq "domain.com") } { [string]$global:SmtpServer = 'smtplb.domain.com' }
    { ((Get-WmiObject Win32_ComputerSystem).Domain -eq "domain2.com") } { [string]$global:SmtpServer = 'mail.domain.com' }
    { ((Get-WmiObject Win32_ComputerSystem).Domain -eq "domain3.com") } { [string]$global:SmtpServer = 'mail.domain.com' }
    { ((Get-WmiObject Win32_ComputerSystem).Domain -eq "domain4.com") } { [string]$global:SmtpServer = 'mail.domain.com' }
    { ((Get-WmiObject Win32_ComputerSystem).Domain -eq "domain5.com") } { [string]$global:SmtpServer = 'mail.domain.com' }
    { ((Get-WmiObject Win32_ComputerSystem).Domain -eq "domain6.com") } { [string]$global:SmtpServer = 'mail.domain.com' }
    { ((Get-WmiObject Win32_ComputerSystem).Domain -eq "domain7.com") } { [string]$global:SmtpServer = 'mail.domain.com' }
    { ((Get-WmiObject Win32_ComputerSystem).Domain -eq "domain8.com") } { [string]$global:SmtpServer = 'smtplb.domain.com' }
}
switch ($CrashCase) { 
    "1" { [string]$global:EmailOperator = 'DL_CSM_DBA@domain.com' } 
    "2" { [string]$global:EmailOperator = 'DL_CSM_DBA_ONCALL@domain.com' } 
    "3" { [string]$global:EmailOperator = 'DL_CSM_DBA_ONCALL@domain.com' } 
    default { [string]$global:EmailOperator = 'DL_CSM_DBA@domain.com' }
}

    
Send-MailMessage -From 'SqlServer@domain.com' -To $EmailOperator -Subject $Subject -body $output -Priority High -SmtpServer $SmtpServer
