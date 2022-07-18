$global:ServerName = [System.Net.Dns]::GetHostName()
Function Start-Cleanup {
    <# 
.SYNOPSIS
   Automate cleaning up a C:\ drive with low disk space

.DESCRIPTION
   Cleans the C: drive's Window Temperary files, Windows SoftwareDistribution folder, 
   the local users Temperary folder, IIS logs(if applicable) and empties the recycling bin. 
   All deleted files will go into a log transcript in $env:TEMP. By default this 
   script leaves files that are newer than 7 days old however this variable can be edited.

.EXAMPLE
   PS C:\> .\Start-Cleanup.ps1
   Save the file to your hard drive with a .PS1 extention and run the file from an elavated PowerShell prompt.

.NOTES
   This script will typically clean up anywhere from 1GB up to 15GB of space from a C: drive.

.FUNCTIONALITY
   PowerShell v3+
#>

    ## Allows the use of -WhatIf
    [CmdletBinding(SupportsShouldProcess = $True)]

    param(
        ## Delete data older then $daystodelete
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 0)]
        $DaysToDelete = 7,

        ## LogFile path for the transcript to be written to
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 1)]
        $LogFile = ("$env:TEMP\" + (get-date -format "MM-d-yy-HH-mm") + '.log'),

        ## All verbose outputs will get logged in the transcript($logFile)
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 2)]
        $VerbosePreference = "Continue",

        ## All errors should be withheld from the console
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 3)]
        $ErrorActionPreference = "SilentlyContinue"
    )

    ## Begin the timer
    $Starters = (Get-Date)
    
    ## Check $VerbosePreference variable, and turns -Verbose on
    Function global:Write-Verbose ( [string]$Message ) {
        if ( $VerbosePreference -ne 'SilentlyContinue' ) {
            Write-Host "$Message" -ForegroundColor 'Green'
        }
    }

    ## Tests if the log file already exists and renames the old file if it does exist
    if (Test-Path $LogFile) {
        ## Renames the log to be .old
        Rename-Item $LogFile $LogFile.old -Verbose -Force
    }
    else {
        ## Starts a transcript in C:\temp so you can see which files were deleted
        Write-Host (Start-Transcript -Path $LogFile) -ForegroundColor Green
    }

    ## Writes a verbose output to the screen for user information
    Write-Host "Retriving current disk percent free for comparison once the script has completed.                 " -NoNewline -ForegroundColor Green
    Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black

    ## Gathers the amount of disk space used before running the script
    $Before = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq "3" } | Select-Object SystemName,
    @{ Name = "Drive" ; Expression = { ( $_.DeviceID ) } },
    @{ Name = "Size (GB)" ; Expression = { "{0:N1}" -f ( $_.Size / 1gb) } },
    @{ Name = "FreeSpace (GB)" ; Expression = { "{0:N1}" -f ( $_.Freespace / 1gb ) } },
    @{ Name = "PercentFree" ; Expression = { "{0:P1}" -f ( $_.FreeSpace / $_.Size ) } } |
    Format-Table -AutoSize |
    Out-String

    Function SoftwareDistributionCleanup {
        ## Stops the windows update service so that c:\windows\softwaredistribution can be cleaned up
        Get-Service -Name wuauserv | Stop-Service -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -Verbose

        ## Deletes the contents of windows software distribution.
        Get-ChildItem "C:\Windows\SoftwareDistribution\*" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -recurse -ErrorAction SilentlyContinue -Verbose
        Write-Host "The Contents of Windows SoftwareDistribution have been removed successfully!                      " -NoNewline -ForegroundColor Green
        Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black
    }

    SoftwareDistributionCleanup # Function call to clean SoftwareDistribution folder

    Function DatabaseFiles {
        ## Cleans up Database files if present under C:\Downloads files
        if (Test-Path "C:\Downloads\") {
            Remove-Item -Path "C:\Downloads\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
        }
        elseif (Test-Path "C:\Download\") {
            Remove-Item -Path "C:\Download\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
        }
        else {
            Write-Host "C:\Downloads or C:\Download does not exist, there is nothing to cleanup.            " -NoNewline -ForegroundColor DarkGray
            Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
        }
        ## Cleans up all users Database download files
        if (Test-Path "C:\SvcPaks\") {
            Remove-Item -Path "C:\SvcPaks\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
        }
        else {
            Write-Host "C:\SvcPaks does not exist, there is nothing to cleanup.            " -NoNewline -ForegroundColor DarkGray
            Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
        }
        if (Test-Path "C:\svc_paks\") {
            Remove-Item -Path "C:\svc_paks\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
        }
        else {
            Write-Host "C:\svc_paks does not exist, there is nothing to cleanup.            " -NoNewline -ForegroundColor DarkGray
            Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
        }
        ## Cleans up Patches Folders for any files
        if (Test-Path "C:\Patches\") {
            Remove-Item -Path "C:\Patches\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
        }
        else {
            Write-Host "C:\Patches\ does not exist, there is nothing to cleanup.            " -NoNewline -ForegroundColor DarkGray
            Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
        }

    }

    DatabaseFiles #Function call for Database Files cleanup


    Function CleanTempFiles {
        ## Deletes the contents of the Windows Temp folder.
        Get-ChildItem "C:\Windows\Temp\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue |
        Where-Object { ($_.CreationTime -lt $(Get-Date).AddDays( - $DaysToDelete)) } | Remove-Item -force -recurse -ErrorAction SilentlyContinue -Verbose
        Write-host "The Contents of Windows Temp have been removed successfully!                                      " -NoNewline -ForegroundColor Green
        Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black


        ## Deletes all files and folders in user's Temp folder older then $DaysToDelete
        Get-ChildItem "C:\users\*\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue |
        Where-Object { ($_.CreationTime -lt $(Get-Date).AddDays( - $DaysToDelete)) } |
        Remove-Item -force -recurse -ErrorAction SilentlyContinue -Verbose
        Write-Host "The contents of `$env:TEMP have been removed successfully!                                         " -NoNewline -ForegroundColor Green
        Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black

        ## Removes all files and folders in user's Temporary Internet Files older then $DaysToDelete
        Get-ChildItem "C:\users\*\AppData\Local\Microsoft\Windows\Temporary Internet Files\*" `
            -Recurse -Force -Verbose -ErrorAction SilentlyContinue |
        Where-Object { ($_.CreationTime -lt $(Get-Date).AddDays( - $DaysToDelete)) } |
        Remove-Item -Force -Recurse -ErrorAction SilentlyContinue -Verbose
        Write-Host "All Temporary Internet Files have been removed successfully!                                      " -NoNewline -ForegroundColor Green
        Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black

        ## Removes *.log from C:\windows\CBS
        if (Test-Path C:\Windows\logs\CBS\) {
            Get-ChildItem "C:\Windows\logs\CBS\*.log" -Recurse -Force -ErrorAction SilentlyContinue |
            remove-item -force -recurse -ErrorAction SilentlyContinue -Verbose
            Write-Host "All CBS logs have been removed successfully!                                                      " -NoNewline -ForegroundColor Green
            Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black
        }
        else {
            Write-Host "C:\inetpub\logs\LogFiles\ does not exist, there is nothing to cleanup.                         " -NoNewline -ForegroundColor DarkGray
            Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
        }

        ## Removes System and User Temp Files - lots of access denied will occur.
        ## Cleans up c:\windows\temp
        if (Test-Path $env:windir\Temp\) {
            Remove-Item -Path "$env:windir\Temp\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
        }
        else {
            Write-Host "C:\Windows\Temp does not exist, there is nothing to cleanup.                                 " -NoNewline -ForegroundColor DarkGray
            Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
        }

        ## Cleans up each users temp folder
        if (Test-Path "C:\Users\*\AppData\Local\Temp\") {
            Remove-Item -Path "C:\Users\*\AppData\Local\Temp\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
        }
        else {
            Write-Host "C:\Users\*\AppData\Local\Temp\ does not exist, there is nothing to cleanup.                  " -NoNewline -ForegroundColor DarkGray
            Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
        }

        ## Cleans up users temporary internet files
        if (Test-Path "C:\Users\*\AppData\Local\Microsoft\Windows\Temporary Internet Files\") {
            Remove-Item -Path "C:\Users\*\AppData\Local\Microsoft\Windows\Temporary Internet Files\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
        }
        else {
            Write-Host "C:\Users\*\AppData\Local\Microsoft\Windows\Temporary Internet Files\ does not exist.              " -NoNewline -ForegroundColor DarkGray
            Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
        }

        ## Cleans up Internet Explorer cache
        if (Test-Path "C:\Users\*\AppData\Local\Microsoft\Windows\IECompatCache\") {
            Remove-Item -Path "C:\Users\*\AppData\Local\Microsoft\Windows\IECompatCache\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
        }
        else {
            Write-Host "C:\Users\*\AppData\Local\Microsoft\Windows\IECompatCache\ does not exist.                         " -NoNewline -ForegroundColor DarkGray
            Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
        }

        ## Cleans up Internet Explorer cache
        if (Test-Path "C:\Users\*\AppData\Local\Microsoft\Windows\IECompatUaCache\") {
            Remove-Item -Path "C:\Users\*\AppData\Local\Microsoft\Windows\IECompatUaCache\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
        }
        else {
            Write-Host "C:\Users\*\AppData\Local\Microsoft\Windows\IECompatUaCache\ does not exist.                       " -NoNewline -ForegroundColor DarkGray
            Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
        }

        ## Cleans up Internet Explorer download history
        if (Test-Path "C:\Users\*\AppData\Local\Microsoft\Windows\IEDownloadHistory\") {
            Remove-Item -Path "C:\Users\*\AppData\Local\Microsoft\Windows\IEDownloadHistory\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
        }
        else {
            Write-Host "C:\Users\*\AppData\Local\Microsoft\Windows\IEDownloadHistory\ does not exist.                     " -NoNewline -ForegroundColor DarkGray
            Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
        }

        ## Cleans up Internet Cache
        if (Test-Path "C:\Users\*\AppData\Local\Microsoft\Windows\INetCache\") {
            Remove-Item -Path "C:\Users\*\AppData\Local\Microsoft\Windows\INetCache\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
        }
        else {
            Write-Host "C:\Users\*\AppData\Local\Microsoft\Windows\INetCache\ does not exist.                             " -NoNewline -ForegroundColor DarkGray
            Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
        }

        ## Cleans up Internet Cookies
        if (Test-Path "C:\Users\*\AppData\Local\Microsoft\Windows\INetCookies\") {
            Remove-Item -Path "C:\Users\*\AppData\Local\Microsoft\Windows\INetCookies\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
        }
        else {
            Write-Host "C:\Users\*\AppData\Local\Microsoft\Windows\INetCookies\ does not exist.                           " -NoNewline -ForegroundColor DarkGray
            Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
        }

        ## Cleans up terminal server cache
        if (Test-Path "C:\Users\*\AppData\Local\Microsoft\Terminal Server Client\Cache\") {
            Remove-Item -Path "C:\Users\*\AppData\Local\Microsoft\Terminal Server Client\Cache\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
        }
        else {
            Write-Host "C:\Users\*\AppData\Local\Microsoft\Terminal Server Client\Cache\ does not exist.                  " -NoNewline -ForegroundColor DarkGray
            Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
        }

        ## Removes the hidden recycling bin.
        if (Test-path 'C:\$Recycle.Bin') {
            Remove-Item 'C:\$Recycle.Bin' -Recurse -Force -Verbose -ErrorAction SilentlyContinue
        }
        else {
            Write-Host "C:\`$Recycle.Bin does not exist, there is nothing to cleanup.                                      " -NoNewline -ForegroundColor DarkGray
            Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
        }
    }

    Write-host "Removing System and User Temp Files                                                               " -NoNewline -ForegroundColor Green
    CleanTempFiles #Function Call to cleanup Team files
    Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black

    ## Cleans IIS Logs older then $DaysToDelete
    if (Test-Path C:\inetpub\logs\LogFiles\) {
        Get-ChildItem "C:\inetpub\logs\LogFiles\*" -Recurse -Force -ErrorAction SilentlyContinue |
        Where-Object { ($_.CreationTime -lt $(Get-Date).AddDays(-60)) } | Remove-Item -Force -Verbose -Recurse -ErrorAction SilentlyContinue
        Write-Host "All IIS Logfiles over $DaysToDelete days old have been removed Successfully!                  " -NoNewline -ForegroundColor Green
        Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black
    }
    else {
        Write-Host "C:\Windows\logs\CBS\ does not exist, there is nothing to cleanup.                                 " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Removes C:\Config.Msi
    if (test-path C:\Config.Msi) {
        remove-item -Path C:\Config.Msi -force -recurse -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "C:\Config.Msi does not exist, there is nothing to cleanup.                                        " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Removes c:\Intel
    if (test-path c:\Intel) {
        remove-item -Path c:\Intel -force -recurse -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "c:\Intel does not exist, there is nothing to cleanup.                                             " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Removes c:\PerfLogs
    if (test-path c:\PerfLogs) {
        remove-item -Path c:\PerfLogs -force -recurse -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "c:\PerfLogs does not exist, there is nothing to cleanup.                                          " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Removes $env:windir\memory.dmp
    if (test-path $env:windir\memory.dmp) {
        remove-item $env:windir\memory.dmp -force -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "C:\Windows\memory.dmp does not exist, there is nothing to cleanup.                                " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Removes Windows Error Reporting files
    if (test-path C:\ProgramData\Microsoft\Windows\WER) {
        Get-ChildItem -Path C:\ProgramData\Microsoft\Windows\WER -Recurse | Remove-Item -force -recurse -Verbose -ErrorAction SilentlyContinue
        Write-host "Deleting Windows Error Reporting files                                                            " -NoNewline -ForegroundColor Green
        Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black
    }
    else {
        Write-Host "C:\ProgramData\Microsoft\Windows\WER does not exist, there is nothing to cleanup.            " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Cleans up minidump
    if (Test-Path $env:windir\minidump\) {
        Remove-Item -Path "$env:windir\minidump\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "$env:windir\minidump\ does not exist, there is nothing to cleanup.                           " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Cleans up prefetch
    if (Test-Path $env:windir\Prefetch\) {
        Remove-Item -Path "$env:windir\Prefetch\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "$env:windir\Prefetch\ does not exist, there is nothing to cleanup.                           " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Cleans up all users windows error reporting
    if (Test-Path "C:\Users\*\AppData\Local\Microsoft\Windows\WER\") {
        Remove-Item -Path "C:\Users\*\AppData\Local\Microsoft\Windows\WER\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "C:\ProgramData\Microsoft\Windows\WER does not exist, there is nothing to cleanup.            " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Turns errors back on
    $ErrorActionPreference = "Continue"

    ## Checks the version of PowerShell
    ## If PowerShell version 4 or below is installed the following will process
    if ($PSVersionTable.PSVersion.Major -le 4) {

        ## Empties the recycling bin, the desktop recyling bin
        $Recycler = (New-Object -ComObject Shell.Application).NameSpace(0xa)
        $Recycler.items() | ForEach-Object { 
            ## If PowerShell version 4 or bewlow is installed the following will process
            Remove-Item -Include $_.path -Force -Recurse -Verbose
            Write-Host "The recycling bin has been cleaned up successfully!                                        " -NoNewline -ForegroundColor Green
            Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black
        }
    }
    elseif ($PSVersionTable.PSVersion.Major -ge 5) {
        ## If PowerShell version 5 is running on the machine the following will process
        Clear-RecycleBin -DriveLetter C:\ -Force -Verbose
        Write-Host "The recycling bin has been cleaned up successfully!                                               " -NoNewline -ForegroundColor Green
        Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black
    }

    ## gathers disk usage after running the cleanup cmdlets.
    $After = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq "3" } | Select-Object SystemName,
    @{ Name = "Drive" ; Expression = { ( $_.DeviceID ) } },
    @{ Name = "Size (GB)" ; Expression = { "{0:N1}" -f ( $_.Size / 1gb) } },
    @{ Name = "FreeSpace (GB)" ; Expression = { "{0:N1}" -f ( $_.Freespace / 1gb ) } },
    @{ Name = "PercentFree" ; Expression = { "{0:P1}" -f ( $_.FreeSpace / $_.Size ) } } |
    Format-Table -AutoSize | Out-String

    ## Restarts wuauserv
    Get-Service -Name wuauserv | Start-Service -ErrorAction SilentlyContinue

    ## Stop timer
    $Enders = (Get-Date)

    ## Calculate amount of seconds your code takes to complete.
    Write-Verbose "Elapsed Time: $(($Enders - $Starters).totalseconds) seconds"
    ## Sends hostname to the console for ticketing purposes.
    Write-Host (Hostname) -ForegroundColor Green

    ## Sends the date and time to the console for ticketing purposes.
    Write-Host (Get-Date | Select-Object -ExpandProperty DateTime) -ForegroundColor Green

    ## Sends the disk usage before running the cleanup script to the console for ticketing purposes.
    Write-Verbose "
    Before: $Before"
    ## Sends the disk usage after running the cleanup script to the console for ticketing purposes.
    Write-Verbose "After: $After"
    ## Completed Successfully!
    $global:ServerName = [System.Net.Dns]::GetHostName()
    $freespace = (Get-WmiObject Win32_LogicalDisk -ComputerName localhost -Filter "DeviceID='C:'").FreeSpace / 1024 / 1024 / 1024
    $CDriveStatus = Get-CimInstance -ComputerName localhost win32_logicaldisk | Where-Object caption -eq "C:" | foreach-object { Write-Output " $($_.caption) $('{0:N2}' -f ($_.Size/1gb)) GB total, $('{0:N2}' -f ($_.FreeSpace/1gb)) GB free " }

    #Validation on free space post script execution, if space less than 10G, email should triggered to DL_CSM_DBA.
    Function FreespaceValidation {
        $global:ServerName = [System.Net.Dns]::GetHostName()
        $myFQDN = (Get-WmiObject win32_computersystem).DNSHostName + "." + (Get-WmiObject win32_computersystem).Domain ;
    
    
        $subject = "Free disk space is less than 10G on volume C: $myFQDN"
        $freespace = (Get-WmiObject Win32_LogicalDisk -ComputerName localhost -Filter "DeviceID='C:'").FreeSpace / 1024 / 1024 / 1024
        $CDriveStatus = Get-CimInstance -ComputerName localhost win32_logicaldisk | Where-Object caption -eq "C:" | foreach-object { Write-Output "$('{0:N2}' -f ($_.FreeSpace/1gb)) GB free of $('{0:N2}' -f ($_.Size/1gb)) GB total" }
        if ($freespace -lt 10) {
            $EmailBody = "<!DOCTYPE html>
                            <html>
                            <body>
                            <body style='font-family: Arial;'><b>System Disk Space Crunch for $Servername.</b></body>
                            <p>Free disk space is less than 10G on $ServerName, Script wasn't able to clear enough space.
                            <br>Currently volume C: has $CDriveStatus, please review the server status manaully.</>
                            </body>
                            </html>"

            $domain = (Get-WmiObject Win32_ComputerSystem).Domain
            switch ($domain) {
                { ((Get-WmiObject Win32_ComputerSystem).Domain -eq "domain1.com") } { [string]$global:SmtpServer = 'smtplb.domain.com' }
                { ((Get-WmiObject Win32_ComputerSystem).Domain -eq "cernerasp.com") } { [string]$global:SmtpServer = 'mail.cernerasp.com' }
            }

            Send-MailMessage -From 'SqlServer@domain.com' -To 'sumit.kumar2@domain.com', 'admin@domain.com' -Subject $subject -bodyashtml $EmailBody -Priority High -SmtpServer $SmtpServer
        }
    }
    FreespaceValidation #Calling Function to varify free space. 
    Write-Host (Stop-Transcript) -ForegroundColor Green
    Write-host "
    Script finished                                                                                   " -NoNewline -ForegroundColor Green
    Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black
}
Start-Cleanup
