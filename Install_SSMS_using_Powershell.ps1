Function sqlPreChecksMenu 
{
    Clear-Host        
    Do
    {
        Clear-Host                                                                       
        Write-Host -Object 'Please choose an option'
        Write-Host     -Object '**********************'
        Write-Host -Object 'SQL Server Pre-checks - Sumit' -ForegroundColor Yellow
        Write-Host     -Object '**********************'
        Write-Host -Object '1. Standalone Server: '
        Write-Host -Object ''
        Write-Host -Object '2. Cluster Environment:  '
        Write-Host -Object ''
        Write-Host -Object '3. Main Menu'
        Write-Host -Object $errout
        $sqlPreChecksMenu = Read-Host -Prompt '(0-3)'
 
        switch ($sqlPreChecksMenu) 
        {
           1 
            {
                sqlStandAloneMenu            
            }
            2 
            {
                sqlClusterMenu
            }
            3 
            {
               Menu
            }   
            default
            {
                $errout = 'Invalid option please try again........Try 0-4 only'
            }
         }
    }
    until ($sqlPreChecksMenu -ne '')
}

Function sqlStandAloneMenu 
{
    Clear-Host        
    Do
    {
        Clear-Host                                                                       
        Write-Host -Object 'Please choose an option'
        Write-Host     -Object '**********************'
        Write-Host -Object 'SQL Server StandAlone Prechecks - Sumit' -ForegroundColor Yellow
        Write-Host     -Object '**********************'
        Write-Host -Object '1. Will Start SQL Server StandAlone Installation '
        Write-Host -Object ''
        Write-Host -Object '2. Need Users Input '
        Write-Host -Object ''
        Write-Host -Object '3. Main Menu'
        Write-Host -Object $errout
        $sqlStandAloneMenu = Read-Host -Prompt '(0-3)'
 
        switch ($sqlStandAloneMenu) 
        {
           1 
            {
                sqlStandAloneMenu            
            }
            2 
            {
                sqlStandAloneMenu
            }
            3 
            {
               Menu
            }   
            default
            {
                $errout = 'Invalid option please try again........Try 0-4 only'
            }
         }
    }
    until ($sqlStandAloneMenu -ne '')
}

Function sqlClusterMenu 
{
    Clear-Host        
    Do
    {
        Clear-Host                                                                       
        Write-Host -Object 'Please choose an option'
        Write-Host     -Object '**********************'
        Write-Host -Object 'SQL Server Cluster Prechecks - Sumit' -ForegroundColor Yellow
        Write-Host     -Object '**********************'
        Write-Host -Object '1. Enter .net Path '
        Write-Host -Object ''
        Write-Host -Object '2. Install Telnet '
        Write-Host -Object ''
        Write-Host -Object '3. Main Menu'
        Write-Host -Object $errout
        $sqlClusterMenu = Read-Host -Prompt '(0-3)'
 
        switch ($sqlClusterMenu) 
        {
           1 
            {
                sqlClusterMenu            
            }
            2 
            {
                sqlClusterMenu
            }
            3 
            {
               Menu
            }   
            default
            {
                $errout = 'Invalid option please try again........Try 0-4 only'
            }
 
        }
    }
    until ($sqlClusterMenu -ne '')
}

Function createDisksMenu 
{
    Clear-Host        
    Do
    {
        Clear-Host                                                                       
        Write-Host -Object 'Please choose an option'
        Write-Host     -Object '**********************'
        Write-Host -Object 'Create Disk Menu - Sumit' -ForegroundColor Yellow
        Write-Host     -Object '**********************'
        Write-Host -Object '1. List Availble Disks:  '
        Write-Host -Object ''
        Write-Host -Object '2. Create disks for Stanalone: '
        Write-Host -Object ''
        Write-Host -Object '3. Create Disks for Cluster :'
        Write-Host -Object ''
        Write-Host -Object '4. Main Menu :'
        Write-Host -Object $errout
        $createDisksMenu = Read-Host -Prompt '(0-4)'
 
        switch ($createDisksMenu) 
        {
           1 
            {
                Get-Disk | Where-Object IsOffline -Eq $True | Format-Table -AutoSize
                pause
                createDisksMenu
					#$USBDriveNumber = Read-Host -Prompt 'Enter USB disk number (or press "Enter" for exit)'
            }
            2 
            {
                createStandaloneDiskMenu
            }
            3 
            {
               createClusterDiskMenu
            }
			4 
            {
               Menu
            }   
            default
            {
                $errout = 'Invalid option please try again........Try 0-4 only'
            }
        }
    }
    until ($createDisksMenu -ne 'q')
}

Function createStandaloneDiskMenu 
{
    Clear-Host        
    Do
    {
        Clear-Host                                                                       
        Write-Host -Object 'Please choose an option'
        Write-Host     -Object '**********************'
        Write-Host -Object 'Disk Creatio  for StandAlone Server - Sumit' -ForegroundColor Yellow
        Write-Host     -Object '**********************'
        Write-Host -Object '1. Create Disks:  '
        Write-Host -Object ''
        Write-Host -Object '2. Go back: '
        Write-Host -Object $errout
        $createStandaloneDiskMenu = Read-Host -Prompt 'Select Option'
 
        switch ($createStandaloneDiskMenu) 
        {
           1 
            {
				$DiskNumber = Read-Host -Prompt 'Enter the Disk Number: '
				$NewFileSystemLabel = Read-Host -Prompt 'Enter the Disk Label/Name '
				$AccessPath = Read-Host -Prompt 'Enter the Mount Point Location '

				If(!(test-path $AccessPath))
				{
					  New-Item -ItemType Directory -Force -Path $AccessPath
				}

				$Disk = Get-Disk $DiskNumber | Where-Object IsOffline -Eq $True
				#$Disk | Clear-Disk -RemoveData -Confirm:$false
				$Disk | Initialize-Disk -PartitionStyle MBR
				$disk | New-Partition -UseMaximumSize -MbrType IFS
				$Partition = Get-Partition -DiskNumber $Disk.Number
				$Partition | Format-Volume -FileSystem NTFS -AllocationUnitSize 65536 -NewFileSystemLabel $NewFileSystemLabel -Confirm:$false
				$Partition | Add-PartitionAccessPath -AccessPath $AccessPath
            }
            2 
            {
                createDisksMenu
            } 
            default
            {
                $errout = 'Invalid option please try again........Try 0-4 only'
            }
         }
    }
    until ($createDisksMenu -ne '')
}

Function sqlInstallationMenu 
{
    Clear-Host        
    Do
    {
        Clear-Host                                                                       
        Write-Host -Object 'Please choose an option'
        Write-Host -Object '**********************'
        Write-Host -Object 'Select the type of Operation: - Sumit' -ForegroundColor Yellow
        Write-Host -Object '**********************'
        Write-Host -Object '1. Copy SQL Server Media:  '
        Write-Host -Object ''
        Write-Host -Object '2. SQL Server Installation:    '
        Write-Host -Object ''
        Write-Host -Object '3. Main Menu :'
        Write-Host -Object $errout
        $sqlInstallationMenu = Read-Host -Prompt '(0-3)'
 
        switch ($sqlInstallationMenu) 
        {
           1 
            {
               sqlInstallationMenu     
            }
            2 
            {
                sqlInstallationTypeMenu
            }
            3 
            {
               Menu
            }
            default
            {
                $errout = 'Invalid option please try again........Try 0-4 only'
            }
 
        }
    }
    until ($sqlInstallationMenu -ne '')
}

Function sqlInstallationTypeMenu 
{
    Clear-Host        
    Do
    {
        Clear-Host                                                                       
        Write-Host -Object 'Please choose an option'
        Write-Host -Object '**********************'
        Write-Host -Object 'SQL Server Installation: - Sumit' -ForegroundColor Yellow
        Write-Host -Object '**********************'
        Write-Host -Object '1. SQL Server Standard Installation:  '
        Write-Host -Object ''
        Write-Host -Object '2. SQL Server Cluster Installation:    '
        Write-Host -Object ''
        Write-Host -Object '3. Main Menu :'
        Write-Host -Object $errout
        $sqlInstallationTypeMenu = Read-Host -Prompt '(0-3)'
 
        switch ($sqlInstallationTypeMenu) 
        {
           1 
            {
               sqlInstallationTask     
            }
            2 
            {
                sqlInstallationTypeMenu
            }
            3 
            {
               sqlInstallationTypeMenu
            }
			4 
            {
               Menu
            }   
            default
            {
                $errout = 'Invalid option please try again........Try 0-4 only'
            }
 
        }
    }
    until ($sqlInstallationTypeMenu -ne '')
}

Function sqlInstallationTask 
{
    Clear-Host        
    Do
    {
        Clear-Host                                                                       
        Write-Host -Object 'Please choose an option'
        Write-Host     -Object '**********************'
        Write-Host -Object 'Disk Creatio  for StandAlone Server - Sumit' -ForegroundColor Yellow
        Write-Host     -Object '**********************'
        Write-Host -Object '1. Start Installation:  '
        Write-Host -Object ''
        Write-Host -Object '2. Go back: '
        Write-Host -Object $errout
        $sqlInstallationTask = Read-Host -Prompt 'Select Option'
 
        switch ($sqlInstallationTask) 
        {
           1 
            {
				#Get No Of CPU On the server
					$colItems = Get-WmiObject -class "Win32_Processor" -namespace "root/CIMV2" 
					$NOfLogicalCPU = 0
					foreach ($objcpu in $colItems)
					{$NOfLogicalCPU = $NOfLogicalCPU + $objcpu.NumberOfLogicalProcessors}
				  
					$DBSERVER=[System.Net.Dns]::GetHostName()

				#Get Rem on the server
					$mem = Get-WmiObject -Class Win32_ComputerSystem  
					$HostPhysicalMemoryGB=$($mem.TotalPhysicalMemory/1Mb) 
					$HostPhysicalMemoryGB=[math]::floor($HostPhysicalMemoryGB)

				#Determine which user is running sql installation script
				$installationAccount=[System.Security.Principal.WindowsIdentity]::GetCurrent().Name

				write-host "`nTotal CPU: $NOfLogicalCPU Total Memory: $HostPhysicalMemoryGB GB and account Installing SQL Server: $installationAccount"   

				#region commonCode
				# Execute this to ensure Powershell has execution rights
				#Set-ExecutionPolicy Unrestricted -Force
				#Set-ExecutionPolicy bypass
				#Import-Module ServerManager 
				#Add-WindowsFeature PowerShell-ISE
				$SQLBinariesLocation= Read-Host -Prompt 'Enter the  SQL Binaries Location'
				$version= Read-Host -Prompt 'Enter the  SQLVersion(2017/2019)'
				$UpdateSource = Read-Host -Prompt 'Enter the  Location for Updates'
				#$INSTANCEDIR="C:\Program Files\Microsoft SQL Server"
				$INSTANCENAME="MSSQLSERVER"
				$SQLSVCACCOUNT=Read-Host -Prompt 'Enter the Service Account'
				$SQLSVCPASSWORD=Read-Host -Prompt 'Enter the Service Account Password'
				$AGTSVCACCOUNT=Read-Host -Prompt 'Enter the Agent Service Account'
				$AGTSVCPASSWORD=Read-Host -Prompt 'Enter the Agent Account Password'
				$SQLSYSADMINACCOUNTS=Read-Host -Prompt 'Windows account(s) to provision as SQL Server system administrators'
				$SAPWD=Read-Host -Prompt 'Enter the SAPassword'
				$SQLBackupDIR=Read-Host -Prompt 'Enter the Backup Directory Location'
				$collation="SQL_Latin1_General_CP1_CI_AS"
				$SQLTempDBDIR=Read-Host -Prompt 'Enter the TEMPDB Data Files Location'
				$SQLTEMPDBLOGDIR=Read-Host -Prompt 'Enter the TEMPDB Log Files Location'
				$SQLUSERDBDIR=Read-Host -Prompt 'Enter the SQL USERs DB Data Files Location'
				$SQLUSERDBLOGDIR=Read-Host -Prompt 'Enter the SQL USERs DB Log Files Location'
				$INSTALLSQLDATADIR=Read-Host -Prompt 'The Database Engine root data directory'
				$SQLFEATURES=Read-Host -Prompt 'Specifies features to install, Supported values are SQLEngine, Replication, FullText, DQ, AS, AS_SPI, RS, RS_SHP, RS_SHPWFE, DQC, Conn, IS, BC, SDK, DREPLAY_CTLR, DREPLAY_CLT, SNAC_SDK, SQLODBC, SQLODBC_SDK, LocalDB, MDS, POLYBASE'


				$message = "
					SQL Instalation ready to proceed please confirm below details: `n

					Server Name: $DBSERVER
					Total CPU: $NOfLogicalCPU
					Total Physical memory: $HostPhysicalMemoryGB MB `n
					SQL Binaries Location=$SQLBinariesLocation `n
					SQL SP DIR=$UpdateSource `n
					SQL CU DIR=$UpdateSource `n
					SQLStartupAccount: $SQLStartupAccount `n
					FEATURES: $SQLFEATURES
					INSTANCE DIR=$INSTANCEDIR
					SQL BACKUP DIR=$SQLBACKUPDIR
					SQL USER DB DIR=$SQLUSERDBDIR
					SQL USER DB LOG DIR=$SQLUSERDBLOGDIR
					SQL TEMP DB DIR=$SQLTEMPDBDIR
					SQL TEMPDB LOG DIR=$SQLTEMPDBLOGDIR
					"  
					write-host $message 

				pause

				$date = Get-Date -format "yyyy-MM-dd HH:mm:ss" 
				Write-Output "$date Starting SQL Server installation"

				if ($version -eq "2017")
				{
					if ($InstanceName -eq "MSSQLSERVER")
					{
					Set-Location $SQLBinariesLocation
					.\setup.exe /QS /ACTION=Install /FEATURES=$SQLFEATURES /ENU /UpdateEnabled=1 /UpdateSource=$UpdateSource /ERRORREPORTING=0 /INSTANCEDIR="C:\Program Files\Microsoft SQL Server" /INSTANCENAME=MSSQLSERVER /SQMREPORTING=0 /SQLSVCACCOUNT=$SQLSVCACCOUNT /SQLSVCPASSWORD=$SQLSVCPASSWORD /AGTSVCACCOUNT=$AGTSVCACCOUNT /AGTSVCPASSWORD=$AGTSVCPASSWORD /SQLSYSADMINACCOUNTS=$SQLSYSADMINACCOUNTS /SAPWD=$SAPWD /AGTSVCSTARTUPTYPE="Automatic" /BROWSERSVCSTARTUPTYPE="Disabled" /INSTALLSQLDATADIR=$INSTALLSQLDATADIR /SQLBACKUPDIR=$SQLBackupDIR /SQLCOLLATION=$collation /SQLSVCSTARTUPTYPE="Automatic" /SQLTEMPDBDIR=$SQLTEMPDBDIR /SQLTEMPDBLOGDIR=$SQLTempDBLogDIR /SQLUSERDBDIR=$SQLUserDBDIR /SQLUSERDBLOGDIR=$SQLUserDBLogDIR /SQLTEMPDBFILECOUNT=4 /IACCEPTSQLSERVERLICENSETERMS
					}
					else
					{
					Set-Location $SQLBinariesLocation
					.\setup.exe /QS /ACTION=Install /FEATURES=$SQLFEATURES /ENU /UpdateEnabled=1 /UpdateSource=$UpdateSource /ERRORREPORTING=0 /INSTANCEDIR="C:\Program Files\Microsoft SQL Server" /INSTANCEID=$InstanceName /INSTANCENAME=$InstanceName /SQMREPORTING=0 /SQLSVCACCOUNT=$SQLSVCACCOUNT /SQLSVCPASSWORD=$SQLSVCPASSWORD /AGTSVCACCOUNT=$AGTSVCACCOUNT /AGTSVCPASSWORD=$AGTSVCPASSWORD /SQLSYSADMINACCOUNTS=$SQLSYSADMINACCOUNTS /SAPWD=$SAPWD /AGTSVCSTARTUPTYPE="Automatic" /BROWSERSVCSTARTUPTYPE="Disabled" /INSTALLSQLDATADIR=$INSTALLSQLDATADIR /SQLBACKUPDIR=$SQLBackupDIR /SQLCOLLATION=$collation /SQLSVCSTARTUPTYPE="Automatic" /SQLTEMPDBDIR=$SQLTEMPDBDIR /SQLTEMPDBLOGDIR=$SQLTempDBLogDIR /SQLUSERDBDIR=$SQLUserDBDIR /SQLUSERDBLOGDIR=$SQLUserDBLogDIR /SQLTEMPDBFILECOUNT=4 /IACCEPTSQLSERVERLICENSETERMS  
					}
				}
				if ($version -eq "2016")
				{
					if ($InstanceName -eq "MSSQLSERVER")
					{
					Set-Location $SQLBinariesLocation
					.\setup.exe /QS /ACTION=Install /FEATURES=$SQLFEATURES /ENU /UpdateEnabled=1 /UpdateSource=$UpdateSource /ERRORREPORTING=0 /INSTANCEDIR="C:\Program Files\Microsoft SQL Server" /INSTANCENAME=MSSQLSERVER /SQMREPORTING=0 /SQLSVCACCOUNT=$SQLSVCACCOUNT /SQLSVCPASSWORD=$SQLSVCPASSWORD /AGTSVCACCOUNT=$AGTSVCACCOUNT /AGTSVCPASSWORD=$AGTSVCPASSWORD /SQLSYSADMINACCOUNTS=$SQLSYSADMINACCOUNTS /SAPWD=$SAPWD /AGTSVCSTARTUPTYPE="Automatic" /BROWSERSVCSTARTUPTYPE="Disabled" /INSTALLSQLDATADIR=$INSTALLSQLDATADIR /SQLBACKUPDIR=$SQLBackupDIR /SQLCOLLATION=$collation /SQLSVCSTARTUPTYPE="Automatic" /SQLTEMPDBDIR=$SQLTEMPDBDIR /SQLTEMPDBLOGDIR=$SQLTempDBLogDIR /SQLUSERDBDIR=$SQLUserDBDIR /SQLUSERDBLOGDIR=$SQLUserDBLogDIR /SQLTEMPDBFILECOUNT=4 /IACCEPTSQLSERVERLICENSETERMS  
					}
					else
					{
					Set-Location $SQLBinariesLocation
					.\setup.exe /QS /ACTION=Install /FEATURES=$SQLFEATURES /ENU /UpdateEnabled=1 /UpdateSource=$UpdateSource /ERRORREPORTING=0 /INSTANCEDIR="C:\Program Files\Microsoft SQL Server" /INSTANCEID=$InstanceName /INSTANCENAME=$InstanceName /SQMREPORTING=0 /SQLSVCACCOUNT=$SQLSVCACCOUNT /AGTSVCACCOUNT=$AGTSVCACCOUNT /AGTSVCPASSWORD=$AGTSVCPASSWORD /SQLSYSADMINACCOUNTS=$SQLSYSADMINACCOUNTS /SAPWD=$SAPWD /AGTSVCSTARTUPTYPE="Automatic" /BROWSERSVCSTARTUPTYPE="Disabled" /INSTALLSQLDATADIR=$INSTALLSQLDATADIR /SQLBACKUPDIR=$SQLBackupDIR /SQLCOLLATION=$collation /SQLSVCSTARTUPTYPE="Automatic" /SQLTEMPDBDIR=$SQLTEMPDBDIR /SQLTEMPDBLOGDIR=$SQLTempDBLogDIR /SQLUSERDBDIR=$SQLUserDBDIR /SQLUSERDBLOGDIR=$SQLUserDBLogDIR /SQLTEMPDBFILECOUNT=4 /IACCEPTSQLSERVERLICENSETERMS  
					}
				}
				elseif ($version -eq "2014")
				{
					if ($InstanceName -eq "MSSQLSERVER")
					{
					Set-Location $SQLBinariesLocation
					.\setup.exe /QS /ACTION=Install /FEATURES=$SQLFEATURES,ADV_SSMS /ENU /UpdateEnabled=1 /UpdateSource=$UpdateSource /ERRORREPORTING=0 /INSTANCEDIR="C:\Program Files\Microsoft SQL Server" /INSTANCENAME=MSSQLSERVER /SQMREPORTING=0 /SQLSVCACCOUNT=$SQLSVCACCOUNT /AGTSVCACCOUNT=$AGTSVCACCOUNT /AGTSVCPASSWORD=$AGTSVCPASSWORD /SQLSYSADMINACCOUNTS=$SQLSYSADMINACCOUNTS /SAPWD=$SAPWD /AGTSVCSTARTUPTYPE="Automatic" /BROWSERSVCSTARTUPTYPE="Disabled" /INSTALLSQLDATADIR=$INSTALLSQLDATADIR /SQLBACKUPDIR=$SQLBackupDIR /SQLCOLLATION=$collation /SQLSVCSTARTUPTYPE="Automatic" /SQLTEMPDBDIR=$SQLTempDBDIR /SQLTEMPDBLOGDIR=$SQLTempDBLogDIR /SQLUSERDBDIR=$SQLUserDBDIR /SQLUSERDBLOGDIR=$SQLUserDBLogDIR /IACCEPTSQLSERVERLICENSETERMS  
					}
					else
					{
					Set-Location $SQLBinariesLocation
					.\setup.exe /QS /ACTION=Install /FEATURES=$SQLFEATURES,ADV_SSMS /ENU /UpdateEnabled=1 /UpdateSource=$UpdateSource /ERRORREPORTING=0 /INSTANCEDIR="C:\Program Files\Microsoft SQL Server" /INSTANCEID=$InstanceName /INSTANCENAME=$InstanceName /SQMREPORTING=0 /SQLSVCACCOUNT=$SQLSVCACCOUNT /AGTSVCACCOUNT=$AGTSVCACCOUNT /AGTSVCPASSWORD=$AGTSVCPASSWORD /SQLSYSADMINACCOUNTS=$SQLSYSADMINACCOUNTS /SAPWD=$SAPWD /AGTSVCSTARTUPTYPE="Automatic" /BROWSERSVCSTARTUPTYPE="Disabled" /INSTALLSQLDATADIR=$INSTALLSQLDATADIR /SQLBACKUPDIR=$SQLBackupDIR /SQLCOLLATION=$collation /SQLSVCSTARTUPTYPE="Automatic" /SQLTEMPDBDIR=$SQLTempDBDIR /SQLTEMPDBLOGDIR=$SQLTempDBLogDIR /SQLUSERDBDIR=$SQLUserDBDIR /SQLUSERDBLOGDIR=$SQLUserDBLogDIR /IACCEPTSQLSERVERLICENSETERMS  
					}
				}
				elseif ($version -eq "2012")
				{
					if ($InstanceName -eq "MSSQLSERVER")
					{
					Set-Location $SQLBinariesLocation
					.\setup.exe /QS /ACTION=Install /FEATURES=$SQLFEATURES,ADV_SSMS /ENU /UpdateEnabled=1 /UpdateSource=$UpdateSource /ERRORREPORTING=0 /INSTANCEDIR="C:\Program Files\Microsoft SQL Server" /INSTANCENAME=MSSQLSERVER /SQMREPORTING=0 /SQLSVCACCOUNT=$SQLSVCACCOUNT /AGTSVCACCOUNT=$AGTSVCACCOUNT /AGTSVCPASSWORD=$AGTSVCPASSWORD /SQLSYSADMINACCOUNTS=$SQLSYSADMINACCOUNTS /SAPWD=$SAPWD /AGTSVCSTARTUPTYPE="Automatic" /BROWSERSVCSTARTUPTYPE="Disabled" /INSTALLSQLDATADIR=$INSTALLSQLDATADIR /SQLBACKUPDIR=$SQLBackupDIR /SQLCOLLATION=$collation /SQLSVCSTARTUPTYPE="Automatic" /SQLTEMPDBDIR=$SQLTempDBDIR /SQLTEMPDBLOGDIR=$SQLTempDBLogDIR /SQLUSERDBDIR=$SQLUserDBDIR /SQLUSERDBLOGDIR=$SQLUserDBLogDIR /IACCEPTSQLSERVERLICENSETERMS 
					}
					else
					{
					Set-Location $SQLBinariesLocation
					.\setup.exe /QS /ACTION=Install /FEATURES=$SQLFEATURES,ADV_SSMS /ENU /UpdateEnabled=1 /UpdateSource=$UpdateSource /ERRORREPORTING=0 /INSTANCEDIR="C:\Program Files\Microsoft SQL Server" /INSTANCEID=$InstanceName /INSTANCENAME=$InstanceName /SQMREPORTING=0 /SQLSVCACCOUNT=$SQLSVCACCOUNT /AGTSVCACCOUNT=$AGTSVCACCOUNT /AGTSVCPASSWORD=$AGTSVCPASSWORD /SQLSYSADMINACCOUNTS=$SQLSYSADMINACCOUNTS /SAPWD=$SAPWD /AGTSVCSTARTUPTYPE="Automatic" /BROWSERSVCSTARTUPTYPE="Disabled" /INSTALLSQLDATADIR=$INSTALLSQLDATADIR /SQLBACKUPDIR=$SQLBackupDIR /SQLCOLLATION=$collation /SQLSVCSTARTUPTYPE="Automatic" /SQLTEMPDBDIR=$SQLTempDBDIR /SQLTEMPDBLOGDIR=$SQLTempDBLogDIR /SQLUSERDBDIR=$SQLUserDBDIR /SQLUSERDBLOGDIR=$SQLUserDBLogDIR /IACCEPTSQLSERVERLICENSETERMS 
    }
}
            }
            2 
            {
                sqlInstallationMenu
            } 
            default
            {
                $errout = 'Invalid option please try again........Try 0-4 only'
            }
         }
    }
    until ($sqlInstallationTask -ne '')
}

Function sqlPostInstallation 
{
    Clear-Host        
    Do
    {
        Clear-Host                                                                       
        Write-Host -Object 'Please choose an option'
        Write-Host -Object '**********************'
        Write-Host -Object 'Select the type of Operation:  - Sumit' -ForegroundColor Yellow
        Write-Host -Object '**********************'
        Write-Host -Object '1. SQL Server Monitoring Jobs:'
        Write-Host -Object ''
        Write-Host -Object '2. Backups Configuration: '
        Write-Host -Object ''
        Write-Host -Object '3. Zabbix Configuration: '
        Write-Host -Object ''
        Write-Host -Object '4. SSMS Installation: '
        Write-Host -Object ''
        Write-Host -Object '5. Main Menu'
        Write-Host -Object $errout
        $sqlPostInstallation = Read-Host -Prompt '(0-5)'
 
        switch ($sqlPostInstallation) 
        {
           1 
            {
                sqlPostInstallation            
            }
            2 
            {
                sqlPostInstallation
            }
            3 
            {
                sqlPostInstallation
            }
			4 
            {
                SSMSInstallationTask
            }
            5 
            {
               Menu
            }   
            default
            {
                $errout = 'Invalid option please try again........Try 0-4 only'
            }
 
        }
    }
    until ($sqlPostInstallation -ne '')
}

Function SSMSInstallationTask 
{
    Clear-Host        
    Do
    {
        Clear-Host                                                                       
        Write-Host -Object 'Please choose an option'
        Write-Host     -Object '**********************'
        Write-Host -Object 'Disk Creatio  for StandAlone Server - Sumit' -ForegroundColor Yellow
        Write-Host     -Object '**********************'
        Write-Host -Object '1. Start SSMS installation:  '
        Write-Host -Object ''
        Write-Host -Object '2. Go back: '
        Write-Host -Object $errout
        $SSMSInstallationTask = Read-Host -Prompt 'Select Option'
 
        switch ($SSMSInstallationTask) 
        {
           1 
            {
				# Set file and folder path for SSMS installer .exe
				$folderpath = Read-Host -Prompt 'Enter the Download Location(C:\SvcPaks) '
				$filepath="$folderpath\SSMS-Setup-ENU.exe"
				 
				#If SSMS not present, download
				if (!(Test-Path $filepath)){
				write-host "Downloading SQL Server Management Studio (SSMS)..."

				$URL = Read-Host -Prompt 'Enter the Latest SSMS URL '
				$clnt = New-Object System.Net.WebClient
				$clnt.DownloadFile($url,$filepath)
				Write-Host "SSMS installer download complete" -ForegroundColor Green
				 
				}
				else { 
				write-host "Located the SQL SSMS Installer binaries, moving on to install..."
				}
				 
				# start the SSMS installer
				write-host "Beginning SQL Server Management Studio (SSMS) install..." -nonewline
				$Parms = " /Install /Quiet /Norestart /Logs log.txt"
				$Prms = $Parms.Split(" ")
				& "$filepath" $Prms | Out-Null
				Write-Host "SSMS installation complete" -ForegroundColor Green
            }
            2 
            {
                createDisksMenu
            } 
            default
            {
                $errout = 'Invalid option please try again........Try 0-4 only'
            }
         }
    }
    until ($createDisksMenu -ne '')
}

Function Menu 
{
    Clear-Host        
    Do
    {
        Clear-Host                                                                       
        Write-Host -Object 'Please choose an option'
        Write-Host     -Object '**********************'
        Write-Host -Object 'Main Menu - Sumit' -ForegroundColor Yellow
        Write-Host     -Object '**********************'
        Write-Host -Object '1. Pre-checks:'
        Write-Host -Object ''
        Write-Host -Object '2. Create Disks: '
        Write-Host -Object ''
        Write-Host -Object '3. SQL Server Installation: '
        Write-Host -Object ''
        Write-Host -Object '4. Post Installation: '
        Write-Host -Object ''
        Write-Host -Object '5. Exit'
        Write-Host -Object $errout
        $Menu = Read-Host -Prompt '(0-5)'
 
        switch ($Menu) 
        {
           1 
            {
                sqlPreChecksMenu            
            }
            2 
            {
                createDisksMenu
            }
            3 
            {
                sqlInstallationMenu
            }
			4 
            {
                sqlPostInstallation
            }
            5 
            {
               return
            }   
            default
            {
                $errout = 'Invalid option please try again........Try 0-4 only'
            }
 
        }
    }
    until ($Menu -ne '')
}   
 
# Launch The Menu
Menu
