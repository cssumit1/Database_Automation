#global Function

if (Get-Module -ListAvailable -Name FailoverClusters) {
	Import-Module FailoverClusters
} 
else {
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	find-module FailoverClusters | Install-Module -AllowClobber -Confirm:$False -Force
	Import-Module FailoverClusters
}

function pause { 
	$ReadHost = $(Write-Host "Press Any Key or Enter to continue..." -ForegroundColor cyan -NoNewLine; Read-Host) 
	$null = $ReadHost 
}

#Code:
Function sqlClusterPreCheckTasks {
	Clear-Host        
	Do {
		Clear-Host
		Write-Host ("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++") -ForegroundColor cyan
		Write-Host ("+                SQL.Next ==> SQL Server Automation                +")  -ForegroundColor cyan
		Write-Host ("+                    Written By: SUMIT KUMAR                       +") -ForegroundColor cyan
		Write-Host ("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++") -ForegroundColor cyan
		Write-Host ("!!             	                                                  !!") -ForegroundColor cyan
		Write-Host ("!!             	                                                  !!") -ForegroundColor cyan
		Write-Host ("--------------------------------------------------------------------") -ForegroundColor cyan
		Write-Host ("!!     	SQL Server Failover Cluster Installation Pre-Checks       !!") -ForegroundColor cyan
		Write-Host ("--------------------------------------------------------------------")    -ForegroundColor cyan
		Write-Host ("!!             	                                                  !!") -ForegroundColor cyan
		Write-Host ******************************************************************** -ForegroundColor cyan
		Write-Host ("                                                                    ")  -ForegroundColor cyan
		Write-Host ******************************************************************** -ForegroundColor cyan
		Write-Host -Object '' 
		Write-Host -Object '' 
		Write-Host -Object '1. Telnet, Failover Clustering and .NET Framework Instalation '
		Write-Host -Object ''
		Write-Host -Object '2. Main Menu'
		Write-Host -Object $errout
		Write-Host -Object '' 
		$sqlClusterPreCheckTasks = Read-Host -Prompt 'Select Options to Proceed'
		Write-Host -Object '' 
 
		switch ($sqlClusterPreCheckTasks) {
			1 {
				Write-Host -Object '' 
				Write-Host -Object 'Installing Install Telnet... ' -ForegroundColor green
				Write-Host -Object '' 
				Install-WindowsFeature Telnet-Client
				Write-Host -Object '' 
				Write-Host -Object 'Installing the Failover Cluster Feature and Tools'  -ForegroundColor green
				Write-Host -Object '' 
				Install-WindowsFeature -Name Failover-Clustering -IncludeManagementTools
				Write-Host -Object '' 
				pause
				Write-Host -Object '' 
				Write-Host -Object 'NET Framework Instalation: Enter to continue'  -ForegroundColor green
				Write-Host -Object '' 
				pause
				Write-Host -Object '' 
				dotNETFrameworkinstall
				Write-Host -Object '' 
				write-host ".NET Framework setup requires a reboot post installation, Press "  -ForegroundColor yellow -NoNewline
				write-host "[ENTER]"  -ForegroundColor green  -NoNewline
				write-host " to restart or "  -ForegroundColor yellow -NoNewline
				write-host "CTRL+C"  -ForegroundColor red   -NoNewline
				write-host " to quit."  -ForegroundColor yellow
				Write-Host -Object ''
				pause
				Restart-Computer
			}
			2 {
				Menu
			}   
			default {
				$errout = 'Invalid option please try again........'
			}
		}
	}
	until ($sqlClusterPreCheckTasks -ne '')
}

Function dotNETFrameworkinstall {
	$defaultWSversion = '2016'
	if (!($global:WSversion = Read-Host -Prompt 'Please Enter the Windows Server Versions (1=2016,2=2019)[default=2016]')) { $WSversion = $defaultWSversion }
	if ((Get-WmiObject Win32_ComputerSystem).Domain -eq "domain.com") {
		if (($WSversion -eq "2016") -or ($WSversion -eq "1")) {
			Install-WindowsFeature Net-Framework-Core -source \\cs-fileshare\cs-filesharepath\General\software\Microsoft\2016\NET35\sxs
		}
		elseif (($WSversion -eq "2019") -or ($WSversion -eq "2")) {
			Write-Host -Object '' 
			$dotNetPath = Read-Host -Prompt 'Enter the .NET Framework Path'
			Install-WindowsFeature Net-Framework-Core -source $dotNetPath
			Write-Host -Object '' 
		}
		else {
			Write-Host -Object '' 
			Write-Host -Object 'Please enter valid input.'    -ForegroundColor red
			Write-Host -Object '' 
		}
	}
	elseif ((Get-WmiObject Win32_ComputerSystem).Domain -eq "domain_2.com") {
		if (($WSversion -eq "2016") -or ($WSversion -eq "1")) {
			Install-WindowsFeature Net-Framework-Core -source \\cs-softwarelocation\ASPSQL_CSM\SQLInstall\NET35\sxs
		}
		elseif (($WSversion -eq "2019") -or ($WSversion -eq "2")) {
			Write-Host -Object '' 
			$dotNetPath = Read-Host -Prompt 'Enter the .NET Framework Path'
			Install-WindowsFeature Net-Framework-Core -source $dotNetPath
			Write-Host -Object '' 
		}
		else {
			Write-Host -Object '' 
			Write-Host -Object 'Please enter valid input.'    -ForegroundColor red
			Write-Host -Object '' 
		}
	}
	else {
		Write-Host -Object '' 
		$dotNetPath = Read-Host -Prompt 'Enter the .NET Framework Path'
		Install-WindowsFeature Net-Framework-Core -source $dotNetPath
		Write-Host -Object '' 
	}
}

Function createStandaloneDiskMenu {
	Clear-Host        
	Do {
		Clear-Host
		Write-Host ("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++") -ForegroundColor cyan
		Write-Host ("+                SQL.Next ==> SQL Server Automation                +")  -ForegroundColor cyan
		Write-Host ("+                    Written By: SUMIT KUMAR                       +") -ForegroundColor cyan
		Write-Host ("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++") -ForegroundColor cyan
		Write-Host ("!!             	                                                  !!") -ForegroundColor cyan
		Write-Host ("!!             	                                                  !!") -ForegroundColor cyan
		Write-Host ("--------------------------------------------------------------------") -ForegroundColor cyan
		Write-Host ("!!                   Create Disks For SQL Server                  !!") -ForegroundColor cyan
		Write-Host ("--------------------------------------------------------------------")    -ForegroundColor cyan
		Write-Host ("!!             Creating and Mounting a File Systems               !!") -ForegroundColor cyan
		Write-Host ******************************************************************** -ForegroundColor cyan
		Write-Host ("                                                                    ")  -ForegroundColor cyan
		Write-Host ******************************************************************** -ForegroundColor cyan
		Write-Host -Object '' 
		Write-Host -Object '' 
		Write-Host -Object '1. Create Disks :  '
		Write-Host -Object ''
		Write-Host -Object '2. Main Menu : '
		Write-Host -Object $errout
		$createStandaloneDiskMenu = Read-Host -Prompt 'Select an Option to Proceed'
		Write-Host -Object ''
		Write-Host -Object '' 
		switch ($createStandaloneDiskMenu) {
			1 {	
				CreateDisksTask
			}
			2 {
				Menu
			} 
			default {
				$errout = 'Invalid option please try again........'
			}
		}
	}
	until ($createStandaloneDiskMenu -ne '')
}

Function CreateDisksTask {
	Clear-Host
	Write-Host ("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++") -ForegroundColor cyan
	Write-Host ("+                SQL.Next ==> SQL Server Automation                +")  -ForegroundColor cyan
	Write-Host ("+                    Written By: SUMIT KUMAR                       +") -ForegroundColor cyan
	Write-Host ("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++") -ForegroundColor cyan
	Write-Host ("!!             	                                                  !!") -ForegroundColor cyan
	Write-Host ("!!             	                                                  !!") -ForegroundColor cyan
	Write-Host ("--------------------------------------------------------------------") -ForegroundColor cyan
	Write-Host ("!!                   Create Disks For SQL Server                  !!") -ForegroundColor cyan
	Write-Host ("--------------------------------------------------------------------")    -ForegroundColor cyan
	Write-Host ("!!             Creating and Mounting a File Systems               !!") -ForegroundColor cyan
	Write-Host ******************************************************************** -ForegroundColor cyan
	Write-Host ("                                                                    ")  -ForegroundColor cyan
	Write-Host ******************************************************************** -ForegroundColor cyan
	Write-Host -Object '' 
	Write-Host -Object '' 
	$DBSERVER = [System.Net.Dns]::GetHostName()
	$AvailableStorageOwner = (get-clustergroup -Name 'Available Storage').ownernode.name
	if (($AvailableStorageOwner -ne $DBSERVER)) {
		Write-Host -Object ''
		write-host "$AvailableStorageOwner"     -ForegroundColor green  -NoNewline
		write-host " Node is the Owner for Available Storage, Moving Available storage to " -ForegroundColor yellow -NoNewline
		write-host "$DBSERVER"     -ForegroundColor green -NoNewline
		write-host " node."     -ForegroundColor yellow
		Write-Host -Object ''
		write-host "Please allow some time..."
		Write-Host -Object ''
		Start-Sleep -Seconds 2
		Get-ClusterGroup -Name 'Available Storage' | Move-ClusterGroup -Node $DBSERVER
		Write-Host -Object ''
	}

	if ((Get-Disk | Where-Object -FilterScript { ($_.PartitionStyle -Eq 'RAW' ) -or ($_.IsOffline -Eq $True) })) {
						
		Write-Host -Object '' 
		Write-Host -Object '      Mount Disk:'  -ForegroundColor green
		Write-Host -Object ''
		MountDiskCreation                         # Calling MOUNT Disks Function

		
		Write-Host -Object '' 
		Write-Host -Object '      Data Disk:'  -ForegroundColor green
		Write-Host -Object ''

		DataDiskCreation                         # Calling DATA Disks Function
		
		Write-Host -Object '' 
		Write-Host -Object '      Log Disk:'  -ForegroundColor green
		Write-Host -Object ''

		LogDiskCreation                         # Calling LOG Disks Function
		Write-Host -Object '' 
		Write-Host -Object '      Backups Disk:'  -ForegroundColor green
		Write-Host -Object ''

		BackupsDiskCreation                         # Calling BACKUPs Disks Function
		Write-Host -Object '' 
		Write-Host -Object '      TempDB Disk:'  -ForegroundColor green
		Write-Host -Object ''

		TempDBDiskCreation                         # Calling TEMPDB Disks Function
		Write-Host -Object '' 
		Write-Host -Object '      System Disk:'  -ForegroundColor green
		Write-Host -Object ''

		SystemDiskCreation                         # Calling SYSTEM Disks Function
		Write-Host -Object '' 
		Write-Host -Object '      Validating Failover Cluster Disks:'  -ForegroundColor green
		Write-Host -Object ''	
		Start-Sleep -Seconds 2
		MountPointChecks                         # Calling List Mount Points Function
		
		Write-Host -Object '' 
		Write-Host -Object '      Creating Directories for Database Files:' -ForegroundColor yellow
		Write-Host -Object ''
		DatabaseDirectoriesCreation                         # Calling Create Database Directories Function
	}
	else {
		Write-Host -Object ''
		Write-Host -Object 'Currently there is '    -ForegroundColor yellow -NoNewline
		Write-Host -Object 'NO'    -ForegroundColor red -NoNewline
		Write-Host -Object ' OFFLINE storage Disks available, please work with storage team to get new Disks Provisioned'    -ForegroundColor yellow
		Write-Host -Object ''
	}
	pause
	Menu
}

Function MountDiskCreation {
	if ((Get-Disk | Where-Object -FilterScript { ($_.PartitionStyle -Eq 'RAW' ) -or ($_.IsOffline -Eq $True) })) {
		Write-Host -Object ''
		$value = Read-Host -Prompt 'You want to Create a Mount Disk? Enter(Yes/Y) to Proceed [default=No]'
		if (($value -eq 'Y') -or ( $value -eq 'Yes' )) {
			Write-Host -Object 'Below are the offline Disks on Server'    -ForegroundColor green
			Get-Disk | Where-Object -FilterScript { ($_.PartitionStyle -Eq 'RAW' ) -or ($_.IsOffline -Eq $True) } | Format-Table -AutoSize
			Write-Host -Object ''
			Write-Host -Object ''
			[int]$DiskNumber = read-host -Prompt 'Enter the 1GB Disk Number for Mounts [int]'
			$DefaultMount = 'Mounts' 
			if (!($global:MountDiskLabel = Read-Host -Prompt 'Enter the Disk Label/Name [Mounts]')) { $MountDiskLabel = $DefaultMount }
			$Disk = Get-Disk $DiskNumber | Where-Object -FilterScript { ($_.PartitionStyle -Eq 'RAW' ) -or ($_.IsOffline -Eq $True) }
			Set-Disk -Number $DiskNumber -IsOffline $False
			$Disk | Clear-Disk -RemoveData -Confirm:$false -ErrorAction Ignore
			$Disk | Initialize-Disk -PartitionStyle MBR -ErrorAction ignore
			if(Get-Disk $DiskNumber | Where-Object -FilterScript { ($_.PartitionStyle -Eq 'GPT' )}){Set-Disk -Number $DiskNumber -PartitionStyle MBR}
			New-Partition -DiskNumber $DiskNumber -DriveLetter Z -UseMaximumSize | Format-Volume -FileSystem NTFS -AllocationUnitSize 65536 -NewFileSystemLabel $MountDiskLabel -Confirm:$false -Force -ErrorAction stop
			Get-Disk $DiskNumber | Add-ClusterDisk
                    
			if (Get-PSDrive | Select-Object -ExpandProperty 'Name' | Select-String -Pattern '^[z]$') {
			}
			else {
				Get-Partition -DiskNumber $Disk.Number | Set-Partition -NewDriveLetter Z
			}
			#$Partition | Add-PartitionAccessPath -AssignDriveLetter "Z"
			$TotalGB = @{Name = "Capacity(GB)"; expression = { [math]::round(($_.Capacity / 1073741824), 2) } }
			$FreeGB = @{Name = "FreeSpace(GB)"; expression = { [math]::round(($_.FreeSpace / 1073741824), 2) } }
			$FreePerc = @{Name = "Free(%)"; expression = { [math]::round(((($_.FreeSpace / 1073741824) / ($_.Capacity / 1073741824)) * 100), 0) } }

			function get-mountpoints {
				$volumes = Get-WmiObject win32_volume -Filter "DriveType='3'"
				$volumes | Select-Object Name, Label, DriveLetter, FileSystem, $TotalGB, $FreeGB, $FreePerc | Format-Table -AutoSize
			}
			Write-Host -Object ''
			Write-Host -Object 'Mount Disk is Created, please review under Mount Points List...'    -ForegroundColor green
			get-mountpoints
		}
		else {
		}
	}
	else {
		Write-Host -Object ''
		Write-Host -Object 'Mount Disk Check error. '    -ForegroundColor red
		Write-Host -Object ''
		Write-Host -Object 'Currently there is '    -ForegroundColor yellow -NoNewline
		Write-Host -Object 'NO'    -ForegroundColor red -NoNewline
		Write-Host -Object ' OFFLINE storage Disks available, please work with storage team to get new Disks Provisioned'    -ForegroundColor yellow
		Write-Host -Object ''
	}
}

Function DataDiskCreation {
	if ((Get-Disk | Where-Object -FilterScript { ($_.PartitionStyle -Eq 'RAW' ) -or ($_.IsOffline -Eq $True) })) {
		Write-Host -Object ''	
		$value = Read-Host -Prompt 'You want to Create a Data Disk? Enter(Yes/Y) to Proceed [default=No]'
		if (($value -eq 'Y') -or ( $value -eq 'Yes' )) {
			Write-Host -Object 'Below are the offline Disks on Server'    -ForegroundColor green
			Get-Disk | Where-Object -FilterScript { ($_.PartitionStyle -Eq 'RAW' ) -or ($_.IsOffline -Eq $True) } | Format-Table -AutoSize
			Write-Host -Object ''
			Write-Host -Object ''
			[int]$DiskNumber = read-host -Prompt 'Enter the Disk Number for Data Files [int] '
			$default = 'Data_D1'
			$defaultAccessPath = 'Z:\Data\Disk1'
			if (!($NewFileSystemLabel = Read-Host -Prompt 'Enter the Disk Label/Name [Data_D1]')) { $NewFileSystemLabel = $default }
			if (!($AccessPath = Read-Host -Prompt 'Enter the Mount Point Location [Z:\Data\Disk1]')) { $AccessPath = $defaultAccessPath }
			If (!(test-path $AccessPath)) {
				New-Item -ItemType Directory -Force -Path $AccessPath | Out-Null
			}
			$Disk = Get-Disk $DiskNumber | Where-Object -FilterScript { ($_.PartitionStyle -Eq 'RAW' ) -or ($_.IsOffline -Eq $True) }
			#$Disk | Clear-Disk -RemoveData -Confirm:$false
			$Disk | Initialize-Disk -PartitionStyle MBR -ErrorAction ignore
			if(Get-Disk $DiskNumber | Where-Object -FilterScript { ($_.PartitionStyle -Eq 'GPT' )}){Set-Disk -Number $DiskNumber -PartitionStyle MBR}
			$disk | New-Partition -UseMaximumSize -MbrType IFS
			$Partition = Get-Partition -DiskNumber $Disk.Number
			$Partition | Format-Volume -FileSystem NTFS -AllocationUnitSize 65536 -NewFileSystemLabel $NewFileSystemLabel -Confirm:$false -Force
			Get-Disk $DiskNumber | Add-ClusterDisk
			$Partition | Add-PartitionAccessPath -AccessPath $AccessPath

			$RemoveAccessPath = Get-Volume | Where-Object -FilterScript { $_.DriveLetter -ne "C" -and $_.DriveLetter -ne "Z" -and $null -ne $_.DriveLetter }
			foreach ($driveletter in $RemoveAccessPath) {
				$RemovePath = $driveletter.driveletter + ':\'
				Get-Volume -Drive $driveletter.driveletter | Get-Partition | Remove-PartitionAccessPath -AccessPath $RemovePath
			}
					
			$TotalGB = @{Name = "Capacity(GB)"; expression = { [math]::round(($_.Capacity / 1073741824), 2) } }
			$FreeGB = @{Name = "FreeSpace(GB)"; expression = { [math]::round(($_.FreeSpace / 1073741824), 2) } }
			$FreePerc = @{Name = "Free(%)"; expression = { [math]::round(((($_.FreeSpace / 1073741824) / ($_.Capacity / 1073741824)) * 100), 0) } }

			function get-mountpoints {
				$volumes = Get-WmiObject win32_volume -Filter "DriveType='3'"
				$volumes | Select-Object Name, Label, DriveLetter, FileSystem, $TotalGB, $FreeGB, $FreePerc | Format-Table -AutoSize
			}
			Write-Host -Object ''
			Write-Host -Object 'Data Disk is Created, please review under Mount Points List...'    -ForegroundColor green
			get-mountpoints
					
			Write-Host -Object ''	
			$newdisk = Read-Host -Prompt 'You want to Create Additional Data Disk? Enter(Yes/Y) to Proceed [default=No]'
			Write-Host -Object ''	
			if (($newdisk -eq 'Y') -or ( $newdisk -eq 'Yes' )) {
				additionalDisk
			}
		}
		else {
		}
	}
	else {
		Write-Host -Object ''
		Write-Host -Object 'Data Disk Check error.'    -ForegroundColor red
		Write-Host -Object ''
		Write-Host -Object 'Currently there is '    -ForegroundColor yellow -NoNewline
		Write-Host -Object 'NO'    -ForegroundColor red -NoNewline
		Write-Host -Object ' OFFLINE storage Disks available, please work with storage team to get new Disks Provisioned'    -ForegroundColor yellow
		Write-Host -Object ''
		pause
	}
}

Function LogDiskCreation {
	if ((Get-Disk | Where-Object -FilterScript { ($_.PartitionStyle -Eq 'RAW' ) -or ($_.IsOffline -Eq $True) })) {
		Write-Host -Object ''
		$value = Read-Host -Prompt 'You want to Create a Log Disk? Enter(Yes/Y) to Proceed [default=No]'
		if (($value -eq 'Y') -or ( $value -eq 'Yes' )) {
			Write-Host -Object 'Below are the offline Disks on Server'    -ForegroundColor green
			Get-Disk | Where-Object -FilterScript { ($_.PartitionStyle -Eq 'RAW' ) -or ($_.IsOffline -Eq $True) } | Format-Table -AutoSize
			Write-Host -Object ''
			Write-Host -Object ''
			[int]$DiskNumber = read-host -Prompt 'Enter the Disk Number for Log Files [int] '
			$default = 'Log_D1'
			$defaultAccessPath = 'Z:\Log\Disk1'
			if (!($NewFileSystemLabel = Read-Host -Prompt 'Enter the Disk Label/Name [Log_D1]')) { $NewFileSystemLabel = $default }
			if (!($AccessPath = Read-Host -Prompt 'Enter the Mount Point Location [Z:\Log\Disk1]')) { $AccessPath = $defaultAccessPath }
			If (!(test-path $AccessPath)) {
				New-Item -ItemType Directory -Force -Path $AccessPath | Out-Null
			}
			$Disk = Get-Disk $DiskNumber | Where-Object -FilterScript { ($_.PartitionStyle -Eq 'RAW' ) -or ($_.IsOffline -Eq $True) }
			#$Disk | Clear-Disk -RemoveData -Confirm:$false
			$Disk | Initialize-Disk -PartitionStyle MBR -ErrorAction ignore
			if(Get-Disk $DiskNumber | Where-Object -FilterScript { ($_.PartitionStyle -Eq 'GPT' )}){Set-Disk -Number $DiskNumber -PartitionStyle MBR}
			$disk | New-Partition -UseMaximumSize -MbrType IFS 
			$Partition = Get-Partition -DiskNumber $Disk.Number
			$Partition | Format-Volume -FileSystem NTFS -AllocationUnitSize 65536 -NewFileSystemLabel $NewFileSystemLabel -Confirm:$false -Force
			Get-Disk $DiskNumber | Add-ClusterDisk
			$Partition | Add-PartitionAccessPath -AccessPath $AccessPath
					
			$RemoveAccessPath = Get-Volume | Where-Object -FilterScript { $_.DriveLetter -ne "C" -and $_.DriveLetter -ne "Z" -and $null -ne $_.DriveLetter }
			foreach ($driveletter in $RemoveAccessPath) {
				$RemovePath = $driveletter.driveletter + ':\'
				Get-Volume -Drive $driveletter.driveletter | Get-Partition | Remove-PartitionAccessPath -AccessPath $RemovePath
			}

			$TotalGB = @{Name = "Capacity(GB)"; expression = { [math]::round(($_.Capacity / 1073741824), 2) } }
			$FreeGB = @{Name = "FreeSpace(GB)"; expression = { [math]::round(($_.FreeSpace / 1073741824), 2) } }
			$FreePerc = @{Name = "Free(%)"; expression = { [math]::round(((($_.FreeSpace / 1073741824) / ($_.Capacity / 1073741824)) * 100), 0) } }

			function get-mountpoints {
				$volumes = Get-WmiObject win32_volume -Filter "DriveType='3'"
				$volumes | Select-Object Name, Label, DriveLetter, FileSystem, $TotalGB, $FreeGB, $FreePerc | Format-Table -AutoSize
			}
			Write-Host -Object ''
			Write-Host -Object 'Log Disk is Created, please review under Mount Points List...'    -ForegroundColor green
			get-mountpoints
					
			Write-Host -Object ''	
			$newdisk = Read-Host -Prompt 'You want to Create Additional Log Disk? Enter(Yes/Y) to Proceed [default=No]'
			Write-Host -Object ''	
			if (($newdisk -eq 'Y') -or ( $newdisk -eq 'Yes' )) {
				additionalDisk
			}
		}
		else {
		}
	}
	else {
		Write-Host -Object ''
		Write-Host -Object 'Log Disk Check error. '    -ForegroundColor red
		Write-Host -Object ''
		Write-Host -Object 'Currently there is '    -ForegroundColor yellow -NoNewline
		Write-Host -Object 'NO'    -ForegroundColor red -NoNewline
		Write-Host -Object ' OFFLINE storage Disks available, please work with storage team to get new Disks Provisioned'    -ForegroundColor yellow
		Write-Host -Object ''
		pause
	}
}

Function BackupsDiskCreation {
	if ((Get-Disk | Where-Object -FilterScript { ($_.PartitionStyle -Eq 'RAW' ) -or ($_.IsOffline -Eq $True) })) {
		Write-Host -Object ''
		$value = Read-Host -Prompt 'You want to Create a Backups Disk? Enter(Yes/Y) to Proceed [default=No]'
		if (($value -eq 'Y') -or ( $value -eq 'Yes' )) {
			Write-Host -Object 'Below are the offline Disks on Server'    -ForegroundColor green
			Get-Disk | Where-Object -FilterScript { ($_.PartitionStyle -Eq 'RAW' ) -or ($_.IsOffline -Eq $True) } | Format-Table -AutoSize
			Write-Host -Object ''
			Write-Host -Object ''
			[int]$DiskNumber = read-host -Prompt 'Enter the Disk Number for Backup Files [int] '
			$default = 'Backups_D1'
			$defaultAccessPath = 'Z:\Backups\Disk1'
			if (!($NewFileSystemLabel = Read-Host -Prompt 'Enter the Disk Label/Name [Backups_D1]')) { $NewFileSystemLabel = $default }
			if (!($AccessPath = Read-Host -Prompt 'Enter the Mount Point Location [Z:\Backups\Disk1]')) { $AccessPath = $defaultAccessPath }
			If (!(test-path $AccessPath)) {
				New-Item -ItemType Directory -Force -Path $AccessPath | Out-Null
			}
			$Disk = Get-Disk $DiskNumber | Where-Object -FilterScript { ($_.PartitionStyle -Eq 'RAW' ) -or ($_.IsOffline -Eq $True) }
			#$Disk | Clear-Disk -RemoveData -Confirm:$false
			$Disk | Initialize-Disk -PartitionStyle MBR -ErrorAction ignore
			if(Get-Disk $DiskNumber | Where-Object -FilterScript { ($_.PartitionStyle -Eq 'GPT' )}){Set-Disk -Number $DiskNumber -PartitionStyle MBR}
			$disk | New-Partition -UseMaximumSize -MbrType IFS 
			$Partition = Get-Partition -DiskNumber $Disk.Number
			$Partition | Format-Volume -FileSystem NTFS -AllocationUnitSize 65536 -NewFileSystemLabel $NewFileSystemLabel -Confirm:$false -Force
			Get-Disk $DiskNumber | Add-ClusterDisk
			$Partition | Add-PartitionAccessPath -AccessPath $AccessPath
                    
			$RemoveAccessPath = Get-Volume | Where-Object -FilterScript { $_.DriveLetter -ne "C" -and $_.DriveLetter -ne "Z" -and $null -ne $_.DriveLetter }
			foreach ($driveletter in $RemoveAccessPath) {
				$RemovePath = $driveletter.driveletter + ':\'
				Get-Volume -Drive $driveletter.driveletter | Get-Partition | Remove-PartitionAccessPath -AccessPath $RemovePath
			}

			$TotalGB = @{Name = "Capacity(GB)"; expression = { [math]::round(($_.Capacity / 1073741824), 2) } }
			$FreeGB = @{Name = "FreeSpace(GB)"; expression = { [math]::round(($_.FreeSpace / 1073741824), 2) } }
			$FreePerc = @{Name = "Free(%)"; expression = { [math]::round(((($_.FreeSpace / 1073741824) / ($_.Capacity / 1073741824)) * 100), 0) } }

			function get-mountpoints {
				$volumes = Get-WmiObject win32_volume -Filter "DriveType='3'"
				$volumes | Select-Object Name, Label, DriveLetter, FileSystem, $TotalGB, $FreeGB, $FreePerc | Format-Table -AutoSize
			}
			Write-Host -Object ''
			Write-Host -Object 'Backups Disk is Created, please review under Mount Points List...'    -ForegroundColor green
			get-mountpoints
					
			Write-Host -Object ''	
			$newdisk = Read-Host -Prompt 'You want to Create Additional Backup Disk? Enter(Yes/Y) to Proceed [default=No]'
			Write-Host -Object ''	
			if (($newdisk -eq 'Y') -or ( $newdisk -eq 'Yes' )) {
				additionalDisk
			}
		}
		else {
		}
	}
	else {
		Write-Host -Object ''
		Write-Host -Object 'Backups Disk Check error. '    -ForegroundColor red
		Write-Host -Object ''
		Write-Host -Object 'Currently there is '    -ForegroundColor yellow -NoNewline
		Write-Host -Object 'NO'    -ForegroundColor red -NoNewline
		Write-Host -Object ' OFFLINE storage Disks available, please work with storage team to get new Disks Provisioned'    -ForegroundColor yellow
		Write-Host -Object ''
		pause
	}
}

Function TempDBDiskCreation {
	if ((Get-Disk | Where-Object -FilterScript { ($_.PartitionStyle -Eq 'RAW' ) -or ($_.IsOffline -Eq $True) })) {
		Write-Host -Object ''
		$value = Read-Host -Prompt 'You want to Create a TempDB Disk? Enter(Yes/Y) to Proceed [default=No]'
		if (($value -eq 'Y') -or ( $value -eq 'Yes' )) {
			Write-Host -Object 'Below are the offline Disks on Server'    -ForegroundColor green
			Get-Disk | Where-Object -FilterScript { ($_.PartitionStyle -Eq 'RAW' ) -or ($_.IsOffline -Eq $True) } | Format-Table -AutoSize
			Write-Host -Object ''
			Write-Host -Object ''
			[int]$DiskNumber = read-host -Prompt 'Enter the Disk Number for TempDB Files [int] '
			$default = 'TempDB_D1'
			$defaultAccessPath = 'Z:\TempDB\Disk1'
			if (!($NewFileSystemLabel = Read-Host -Prompt 'Enter the Disk Label/Name [TempDB_D1]')) { $NewFileSystemLabel = $default }
			if (!($AccessPath = Read-Host -Prompt 'Enter the Mount Point Location [Z:\TempDB\Disk1]')) { $AccessPath = $defaultAccessPath }
			If (!(test-path $AccessPath)) {
				New-Item -ItemType Directory -Force -Path $AccessPath | Out-Null
			}
			$Disk = Get-Disk $DiskNumber | Where-Object -FilterScript { ($_.PartitionStyle -Eq 'RAW' ) -or ($_.IsOffline -Eq $True) }
			#$Disk | Clear-Disk -RemoveData -Confirm:$false
			$Disk | Initialize-Disk -PartitionStyle MBR -ErrorAction ignore
			if(Get-Disk $DiskNumber | Where-Object -FilterScript { ($_.PartitionStyle -Eq 'GPT' )}){Set-Disk -Number $DiskNumber -PartitionStyle MBR}
			$disk | New-Partition -UseMaximumSize -MbrType IFS 
			$Partition = Get-Partition -DiskNumber $Disk.Number
			$Partition | Format-Volume -FileSystem NTFS -AllocationUnitSize 65536 -NewFileSystemLabel $NewFileSystemLabel -Confirm:$false -Force
			Get-Disk $DiskNumber | Add-ClusterDisk
			$Partition | Add-PartitionAccessPath -AccessPath $AccessPath
					
			$RemoveAccessPath = Get-Volume | Where-Object -FilterScript { $_.DriveLetter -ne "C" -and $_.DriveLetter -ne "Z" -and $null -ne $_.DriveLetter }
			foreach ($driveletter in $RemoveAccessPath) {
				$RemovePath = $driveletter.driveletter + ':\'
				Get-Volume -Drive $driveletter.driveletter | Get-Partition | Remove-PartitionAccessPath -AccessPath $RemovePath
			}

			$TotalGB = @{Name = "Capacity(GB)"; expression = { [math]::round(($_.Capacity / 1073741824), 2) } }
			$FreeGB = @{Name = "FreeSpace(GB)"; expression = { [math]::round(($_.FreeSpace / 1073741824), 2) } }
			$FreePerc = @{Name = "Free(%)"; expression = { [math]::round(((($_.FreeSpace / 1073741824) / ($_.Capacity / 1073741824)) * 100), 0) } }

			function get-mountpoints {
				$volumes = Get-WmiObject win32_volume -Filter "DriveType='3'"
				$volumes | Select-Object Name, Label, DriveLetter, FileSystem, $TotalGB, $FreeGB, $FreePerc | Format-Table -AutoSize
			}
			Write-Host -Object ''
			Write-Host -Object 'TempDB Disk is Created, please review under Mount Points List...'    -ForegroundColor green
			get-mountpoints
					
			Write-Host -Object ''	
			$newdisk = Read-Host -Prompt 'You want to Create Additional TempDB Disk? Enter(Yes/Y) to Proceed [default=No]'
			Write-Host -Object ''	
			if (($newdisk -eq 'Y') -or ( $newdisk -eq 'Yes' )) {
				additionalDisk
			}
		}
		else {
		}
	}
	else {
		Write-Host -Object ''
		Write-Host -Object 'TempDB Disk Check error. '    -ForegroundColor red
		Write-Host -Object ''
		Write-Host -Object 'Currently there is '    -ForegroundColor yellow -NoNewline
		Write-Host -Object 'NO'    -ForegroundColor red -NoNewline
		Write-Host -Object ' OFFLINE storage Disks available, please work with storage team to get new Disks Provisioned'    -ForegroundColor yellow
		Write-Host -Object ''
		pause
	}
}

Function SystemDiskCreation {
	if ((Get-Disk | Where-Object -FilterScript { ($_.PartitionStyle -Eq 'RAW' ) -or ($_.IsOffline -Eq $True) })) {
		Write-Host -Object ''
		$value = Read-Host -Prompt 'You want to Create a System Disk? Enter(Yes/Y) to Proceed [default=No]'
		if (($value -eq 'Y') -or ( $value -eq 'Yes' )) {
			Write-Host -Object 'Below are the offline Disks on Server'    -ForegroundColor green
			Get-Disk | Where-Object -FilterScript { ($_.PartitionStyle -Eq 'RAW' ) -or ($_.IsOffline -Eq $True) } | Format-Table -AutoSize
			Write-Host -Object ''
			Write-Host -Object ''
			[int]$DiskNumber = read-host -Prompt 'Enter the Disk Number for System Binaries [int] '
			$default = 'System_D1'
			$defaultAccessPath = 'Z:\System\Disk1'
			if (!($NewFileSystemLabel = Read-Host -Prompt 'Enter the Disk Label/Name [System_D1]')) { $NewFileSystemLabel = $default }
			if (!($AccessPath = Read-Host -Prompt 'Enter the Mount Point Location [Z:\System\Disk1]')) { $AccessPath = $defaultAccessPath }
			If (!(test-path $AccessPath)) {
				New-Item -ItemType Directory -Force -Path $AccessPath | Out-Null
			}
			$Disk = Get-Disk $DiskNumber | Where-Object -FilterScript { ($_.PartitionStyle -Eq 'RAW' ) -or ($_.IsOffline -Eq $True) }
			#$Disk | Clear-Disk -RemoveData -Confirm:$false
			$Disk | Initialize-Disk -PartitionStyle MBR -ErrorAction ignore
			if(Get-Disk $DiskNumber | Where-Object -FilterScript { ($_.PartitionStyle -Eq 'GPT' )}){Set-Disk -Number $DiskNumber -PartitionStyle MBR}
			$disk | New-Partition -UseMaximumSize -MbrType IFS 
			$Partition = Get-Partition -DiskNumber $Disk.Number
			$Partition | Format-Volume -FileSystem NTFS -AllocationUnitSize 65536 -NewFileSystemLabel $NewFileSystemLabel -Confirm:$false -Force
			Get-Disk $DiskNumber | Add-ClusterDisk
			$Partition | Add-PartitionAccessPath -AccessPath $AccessPath
					
			$RemoveAccessPath = Get-Volume | Where-Object -FilterScript { $_.DriveLetter -ne "C" -and $_.DriveLetter -ne "Z" -and $null -ne $_.DriveLetter }
			foreach ($driveletter in $RemoveAccessPath) {
				$RemovePath = $driveletter.driveletter + ':\'
				Get-Volume -Drive $driveletter.driveletter | Get-Partition | Remove-PartitionAccessPath -AccessPath $RemovePath
			}

			$TotalGB = @{Name = "Capacity(GB)"; expression = { [math]::round(($_.Capacity / 1073741824), 2) } }
			$FreeGB = @{Name = "FreeSpace(GB)"; expression = { [math]::round(($_.FreeSpace / 1073741824), 2) } }
			$FreePerc = @{Name = "Free(%)"; expression = { [math]::round(((($_.FreeSpace / 1073741824) / ($_.Capacity / 1073741824)) * 100), 0) } }

			function get-mountpoints {
				$volumes = Get-WmiObject win32_volume -Filter "DriveType='3'"
				$volumes | Select-Object Name, Label, DriveLetter, FileSystem, $TotalGB, $FreeGB, $FreePerc | Format-Table -AutoSize
			}
			Write-Host -Object ''
			Write-Host -Object 'System Disk is Created, please review under Mount Points List...'    -ForegroundColor green
			get-mountpoints
		}
		else {
		}
	}
	else {
		Write-Host -Object ''
		Write-Host -Object 'System Disk Check error. '    -ForegroundColor red
		Write-Host -Object ''
		Write-Host -Object 'Currently there is '    -ForegroundColor yellow -NoNewline
		Write-Host -Object 'NO'    -ForegroundColor red -NoNewline
		Write-Host -Object ' OFFLINE storage Disks available, please work with storage team to get new Disks Provisioned'    -ForegroundColor yellow
		Write-Host -Object ''
		pause
	}
}

Function additionalDisk {
	if ((Get-Disk | Where-Object -FilterScript { ($_.PartitionStyle -Eq 'RAW' ) -or ($_.IsOffline -Eq $True) })) {
		Write-Host -Object ''	
		Write-Host -Object 'Below are the offline Disks on Server'    -ForegroundColor green
		Get-Disk | Where-Object -FilterScript { ($_.PartitionStyle -Eq 'RAW' ) -or ($_.IsOffline -Eq $True) } | Format-Table -AutoSize
		Write-Host -Object ''
		Write-Host -Object ''
		[int]$DiskNumber = read-host -Prompt 'Enter the Disk Number [int] '
		$default = 'Data_D2'
		$defaultAccessPath = 'Z:\Data\Disk2'
		if (!($NewFileSystemLabel = Read-Host -Prompt 'Enter the Disk Label/Name [Data_D2]')) { $NewFileSystemLabel = $default }
		if (!($AccessPath = Read-Host -Prompt 'Enter the Mount Point Location [Z:\Data\Disk2]')) { $AccessPath = $defaultAccessPath }
		If (!(test-path $AccessPath)) {
			New-Item -ItemType Directory -Force -Path $AccessPath | Out-Null
		}
		$Disk = Get-Disk $DiskNumber | Where-Object -FilterScript { ($_.PartitionStyle -Eq 'RAW' ) -or ($_.IsOffline -Eq $True) }
		#$Disk | Clear-Disk -RemoveData -Confirm:$false
		$Disk | Initialize-Disk -PartitionStyle MBR -ErrorAction ignore
		if(Get-Disk $DiskNumber | Where-Object -FilterScript { ($_.PartitionStyle -Eq 'GPT' )}){Set-Disk -Number $DiskNumber -PartitionStyle MBR}
		$disk | New-Partition -UseMaximumSize -MbrType IFS 
		$Partition = Get-Partition -DiskNumber $Disk.Number
		$Partition | Format-Volume -FileSystem NTFS -AllocationUnitSize 65536 -NewFileSystemLabel $NewFileSystemLabel -Confirm:$false -Force
		Get-Disk $DiskNumber | Add-ClusterDisk
		$Partition | Add-PartitionAccessPath -AccessPath $AccessPath
					
		$RemoveAccessPath = Get-Volume | Where-Object -FilterScript { $_.DriveLetter -ne "C" -and $_.DriveLetter -ne "Z" -and $null -ne $_.DriveLetter }
		foreach ($driveletter in $RemoveAccessPath) {
			$RemovePath = $driveletter.driveletter + ':\'
			Get-Volume -Drive $driveletter.driveletter | Get-Partition | Remove-PartitionAccessPath -AccessPath $RemovePath
		}

		$TotalGB = @{Name = "Capacity(GB)"; expression = { [math]::round(($_.Capacity / 1073741824), 2) } }
		$FreeGB = @{Name = "FreeSpace(GB)"; expression = { [math]::round(($_.FreeSpace / 1073741824), 2) } }
		$FreePerc = @{Name = "Free(%)"; expression = { [math]::round(((($_.FreeSpace / 1073741824) / ($_.Capacity / 1073741824)) * 100), 0) } }

		function get-mountpoints {
			$volumes = Get-WmiObject win32_volume -Filter "DriveType='3'"
			$volumes | Select-Object Name, Label, DriveLetter, FileSystem, $TotalGB, $FreeGB, $FreePerc | Format-Table -AutoSize
		}
		Write-Host -Object ''
		Write-Host -Object 'Disk is Created, please review under Mount Points List...'    -ForegroundColor green
		get-mountpoints
					
		Write-Host -Object ''	
		$newdisk = Read-Host -Prompt 'You want to Create Additional Disk? Enter(Yes/Y) to Proceed [default=No]'
		Write-Host -Object ''	
		if (($newdisk -eq 'Y') -or ( $newdisk -eq 'Yes' )) {
			additionalDisk
		}
		else {
		}
	}
	else {
		Write-Host -Object ''
		Write-Host -Object 'Disk Check error.'    -ForegroundColor red
		Write-Host -Object ''
		Write-Host -Object 'Currently there is '    -ForegroundColor yellow -NoNewline
		Write-Host -Object 'NO'    -ForegroundColor red -NoNewline
		Write-Host -Object ' OFFLINE storage Disks available, please work with storage team to get new Disks Provisioned'    -ForegroundColor yellow
		Write-Host -Object ''
		pause
	}
}

Function QuorumDiskCreation {
	if ((Get-Disk | Where-Object -FilterScript { ($_.PartitionStyle -Eq 'RAW' ) -or ($_.IsOffline -Eq $True) })) {
		Write-Host -Object ''
		$value = Read-Host -Prompt 'You want to Create a Quorum Disk? Enter(Yes/Y) to Proceed [default=No]'
		if (($value -eq 'Y') -or ( $value -eq 'Yes' )) {
			Write-Host -Object 'Below are the offline Disks on Server'    -ForegroundColor green
			Get-Disk | Where-Object -FilterScript { ($_.PartitionStyle -Eq 'RAW' ) -or ($_.IsOffline -Eq $True) } | Format-Table -AutoSize
			Write-Host -Object ''
			Write-Host -Object ''
			[int]$DiskNumber = read-host -Prompt 'Enter the 1GB Disk Number for Quorum Disk [int]'
			$DefaultQuorum = 'Quorum' 
			if (!($global:QuorumDiskLabel = Read-Host -Prompt 'Enter the Disk Label/Name [Quorum]')) { $QuorumDiskLabel = $DefaultQuorum }
			$Disk = Get-Disk $DiskNumber | Where-Object -FilterScript { ($_.PartitionStyle -Eq 'RAW' ) -or ($_.IsOffline -Eq $True) }
			Set-Disk -Number $DiskNumber -IsOffline $False
			$Disk | Clear-Disk -RemoveData -Confirm:$false -ErrorAction Ignore
			$Disk | Initialize-Disk -PartitionStyle MBR -ErrorAction ignore
			if(Get-Disk $DiskNumber | Where-Object -FilterScript { ($_.PartitionStyle -Eq 'GPT' )}){Set-Disk -Number $DiskNumber -PartitionStyle MBR}
			New-Partition -DiskNumber $DiskNumber -DriveLetter Q -UseMaximumSize | Format-Volume -FileSystem NTFS -AllocationUnitSize 65536 -NewFileSystemLabel $QuorumDiskLabel -Confirm:$false -Force -ErrorAction stop
			Get-Disk $DiskNumber | Add-ClusterDisk
                    
			if (Get-PSDrive | Select-Object -ExpandProperty 'Name' | Select-String -Pattern '^[Q]$') {
			}
			else {
				Get-Partition -DiskNumber $Disk.Number | Set-Partition -NewDriveLetter Q
			}
			#$Partition | Add-PartitionAccessPath -AssignDriveLetter "Z"
			$TotalGB = @{Name = "Capacity(GB)"; expression = { [math]::round(($_.Capacity / 1073741824), 2) } }
			$FreeGB = @{Name = "FreeSpace(GB)"; expression = { [math]::round(($_.FreeSpace / 1073741824), 2) } }
			$FreePerc = @{Name = "Free(%)"; expression = { [math]::round(((($_.FreeSpace / 1073741824) / ($_.Capacity / 1073741824)) * 100), 0) } }

			function get-mountpoints {
				$volumes = Get-WmiObject win32_volume -Filter "DriveType='3'"
				$volumes | Select-Object Name, Label, DriveLetter, FileSystem, $TotalGB, $FreeGB, $FreePerc | Format-Table -AutoSize
			}
			Write-Host -Object ''
			Write-Host -Object 'Quorum Disk is Created, please review under Mount Points List...'    -ForegroundColor green
			get-mountpoints
		}
		else {
		}
	}
	else {
		Write-Host -Object ''
		Write-Host -Object 'Mount Disk Check error. '    -ForegroundColor red
		Write-Host -Object ''
		Write-Host -Object 'Currently there is '    -ForegroundColor yellow -NoNewline
		Write-Host -Object 'NO'    -ForegroundColor red -NoNewline
		Write-Host -Object ' OFFLINE storage Disks available, please work with storage team to get new Disks Provisioned'    -ForegroundColor yellow
		Write-Host -Object ''
	}
}
Function MountPointChecks {	
	Write-Host -Object '      Locating Mount Points...'  -ForegroundColor yellow
	Write-Host -Object ''	
	Start-Sleep -Seconds 3
	Write-Host -Object '' 
	Write-Host -Object '      Renaming Failover Cluster Disks...'  -ForegroundColor yellow
	Write-Host -Object ''	
	Start-Sleep -Seconds 3
	# Rename Cluster Disks as local Disk Names in Disk Management:
	$ClusterDisks = Get-CimInstance -ClassName MSCluster_Resource -Namespace root/mscluster -Filter "type = 'Physical Disk'"
	foreach ($Disk in $ClusterDisks) {
		$DiskResource = Get-CimAssociatedInstance -InputObject $Disk -ResultClass MSCluster_DiskPartition
		if (-not ($DiskResource.VolumeLabel -eq $Disk.Name)) {
			Invoke-CimMethod -InputObject $Disk -MethodName Rename -arguments @{newName = $DiskResource.VolumeLabel }
		}
	}


	# Show the created mount Points:
	$TotalGB = @{Name = "Capacity(GB)"; expression = { [math]::round(($_.Capacity / 1073741824), 2) } }
	$FreeGB = @{Name = "FreeSpace(GB)"; expression = { [math]::round(($_.FreeSpace / 1073741824), 2) } }
	$FreePerc = @{Name = "Free(%)"; expression = { [math]::round(((($_.FreeSpace / 1073741824) / ($_.Capacity / 1073741824)) * 100), 0) } }

	function get-mountpoints {
		$volumes = Get-WmiObject win32_volume -Filter "DriveType='3'"
		$volumes | Select-Object Name, Label, DriveLetter, FileSystem, $TotalGB, $FreeGB, $FreePerc | Format-Table -AutoSize
	}


	Write-Host -Object ''
	Write-Host -Object 'Below are the Mount Points Created!'    -ForegroundColor green
	get-mountpoints
	Write-Host -Object '' 
	Write-Host -Object 'Cluster Disks Renaed as Disk Managment Labels, Please review!'  -ForegroundColor green
	Write-Host -Object ''	
					
	$resources = Get-WmiObject -namespace root\MSCluster MSCluster_Resource -filter "Type='Physical Disk'"
	$resources | ForEach-Object {
		$res = $_
		$Disks = $res.GetRelated("MSCluster_Disk")
		$Disks | ForEach-Object {
			$_.GetRelated("MSCluster_DiskPartition") |
			Select-Object @{N = "Name"; E = { $res.Name } }, @{N = "Status"; E = { $res.State } }, Path, VolumeLabel, @{Name = "Size (GB)"; Expression = { [int]($_.TotalSize / 1024) } }, FreeSpace 
		}
	} | Format-Table
}


Function DatabaseDirectoriesCreation {
	Write-Host -Object ''
	$default = 'Yes'
	if (!($value = Read-Host -Prompt 'You want to Create Required Data/Log Files Directories? Enter([Yes]/Y) to Proceed')) { $value = $default }
	if (($value -eq 'Y') -or ( $value -eq 'Yes' )) {
		Write-Host -Object ''
		Write-Host -Object 'Creating Required Directories...!'    -ForegroundColor green
		Write-Host -Object ''
		If (!(test-path Z:\Backups\Disk1\sql_bak)) {
			New-Item -ItemType Directory -Force -Path Z:\Backups\Disk1\sql_bak | Out-Null
		}
		If (!(test-path Z:\TempDB\Disk1\sql_dat)) {
			New-Item -ItemType Directory -Force -Path Z:\TempDB\Disk1\sql_dat | Out-Null
		}
		If (!(test-path Z:\Log\Disk1\sql_log)) {
			New-Item -ItemType Directory -Force -Path Z:\Log\Disk1\sql_log | Out-Null
		}
		If (!(test-path Z:\Data\Disk1\sql_dat)) {
			New-Item -ItemType Directory -Force -Path Z:\Data\Disk1\sql_dat | Out-Null
		}
	}
	else {
	}
	if ((test-path Z:\Data\Disk1\sql_dat)) {
		Write-Host -Object ''
		Write-Host -Object 'Data Directory Created Successfully!!'    -ForegroundColor green
		Write-Host -Object ''
		Write-Host -Object 'Z:\Data\Disk1\sql_dat'    -ForegroundColor yellow
		Write-Host -Object ''
	}
	else {
		Write-Host -Object ''
		Write-Host -Object 'Data Directory is missing, please run below command to create it manaully.'    -ForegroundColor red
		Write-Host -Object ''
		Write-Host -Object 'New-Item -ItemType Directory -Force -Path Z:\Data\Disk1\sql_dat'    -ForegroundColor yellow
		Write-Host -Object ''
	}
					
	if ((test-path Z:\Log\Disk1\sql_log)) {
		Write-Host -Object ''
		Write-Host -Object 'Log Directory Created Successfully!!'    -ForegroundColor green
		Write-Host -Object ''
		Write-Host -Object 'Z:\Log\Disk1\sql_log'    -ForegroundColor yellow
		Write-Host -Object ''
	}
	else {
		Write-Host -Object ''
		Write-Host -Object 'Log Directory is missing, please run below command to create it manaully.'    -ForegroundColor red
		Write-Host -Object ''
		Write-Host -Object 'New-Item -ItemType Directory -Force -Path Z:\Log\Disk1\sql_log'    -ForegroundColor yellow
		Write-Host -Object ''
	}
					
	if ((test-path Z:\TempDB\Disk1\sql_dat)) {
		Write-Host -Object ''
		Write-Host -Object 'TempDB Directory Created Successfully!!'    -ForegroundColor green
		Write-Host -Object ''
		Write-Host -Object 'Z:\TempDB\Disk1\sql_dat'    -ForegroundColor yellow
		Write-Host -Object ''
	}
	else {
		Write-Host -Object ''
		Write-Host -Object 'TempDB Directory is missing, please run below command to create it manaully.'    -ForegroundColor red
		Write-Host -Object ''
		Write-Host -Object 'New-Item -ItemType Directory -Force -Path Z:\TempDB\Disk1\sql_dat'    -ForegroundColor yellow
		Write-Host -Object ''
	}
					
	if ((test-path Z:\Backups\Disk1\sql_bak)) {
		Write-Host -Object ''
		Write-Host -Object 'Backup Directory Created Successfully!!'    -ForegroundColor green
		Write-Host -Object ''
		Write-Host -Object 'Z:\Backups\Disk1\sql_bak'    -ForegroundColor yellow
		Write-Host -Object ''
	}
	else {
		Write-Host -Object ''
		Write-Host -Object 'Backup Directory is missing, please run below command to create it manaully.'    -ForegroundColor red
		Write-Host -Object ''
		Write-Host -Object 'New-Item -ItemType Directory -Force -Path Z:\Backups\Disk1\sql_bak'    -ForegroundColor yellow
		Write-Host -Object ''
	}
					
	if ((test-path Z:\System\Disk1)) {
		Write-Host -Object ''
		Write-Host -Object 'System Directory Created Successfully!!'    -ForegroundColor green
		Write-Host -Object ''
		Write-Host -Object 'Z:\System\Disk1'    -ForegroundColor yellow
		Write-Host -Object ''
	}
	else {
		Write-Host -Object ''
		Write-Host -Object 'System Disk is missing, please review and mount it manaully.'    -ForegroundColor red
		Write-Host -Object ''
	}
}

Function sqlAccounts {
	Write-Host -Object ''
	$global:Environment = Read-Host -Prompt 'Please enter DB Environment(1=Prod,2=NonProd)'
	Write-Host -Object ''
	if ((Get-WmiObject Win32_ComputerSystem).Domain -eq "domain.com") {
		if (($Environment -eq "PROD") -or ($Environment -eq "1")) {
			$global:SQLSVCACCOUNT = "CSSUMIT_DOMAIN\svcMssqlprd"
			write-host "Service Account will be used for Prod(Database Services/Agent)("$SQLSVCACCOUNT")"     -ForegroundColor yellow
			$global:SQLSVCPASSWORD = Get-Content -Path "\\cssumitwhq4\CSMDBA\DB\SQLInstall\prd_Account.txt"
			Write-Host -Object ''
			pause
		}
		elseif (($Environment -eq "NONPROD") -or ($Environment -eq "2")) {
			$global:SQLSVCACCOUNT = "CSSUMIT_DOMAIN\svcMssqlnonprd"
			write-host "Service Account will be used for Non-Prod(Database Services/Agent)("$SQLSVCACCOUNT")"     -ForegroundColor yellow
			$global:SQLSVCPASSWORD = Get-Content -Path "\\cssumitwhq4\CSMDBA\DB\SQLInstall\nonprd_Account.txt"
			Write-Host -Object ''
			pause
		}
		else {
			Write-Host -Object 'Please Provide a Valid Environment, expected values (1=Prod,2=NonProd)'   -ForegroundColor red
			Write-Host -Object ''
			pause
			sqlAccounts
		}
	}		
	elseif ((Get-WmiObject Win32_ComputerSystem).Domain -eq "domain_2.com") {
		if (($Environment -eq "PROD") -or ($Environment -eq "1")) {
			$global:SQLSVCACCOUNT = "domain_2.com\svcMssqlprd"
			Write-Host -Object ''
			write-host "Service Account will be used for Prod(Database Services/Agent)("$SQLSVCACCOUNT")"     -ForegroundColor green
			$global:SQLSVCPASSWORD = Get-Content -Path "\\cs-softwarelocation\ASPSQL_CSM\SQLInstall\prd_Account.txt"
			Write-Host -Object ''
			pause
		}
		elseif (($Environment -eq "NONPROD") -or ($Environment -eq "2")) {
			$global:SQLSVCACCOUNT = "domain_2.com\svcMssqlnonprd"
			Write-Host -Object ''
			write-host "Service Account will be used for Non-Prod(Database Services/Agent)("$SQLSVCACCOUNT")"     -ForegroundColor green
			$global:SQLSVCPASSWORD = Get-Content -Path "\\cs-softwarelocation\ASPSQL_CSM\SQLInstall\nonprd_Account.txt"
			Write-Host -Object ''
			pause
		}
		else {
			Write-Host -Object 'Please Provide a Valid Environment, expected values (1=Prod,2=NonProd)' -ForegroundColor red
			Write-Host -Object ''
			pause
			sqlAccounts
		}
	}
	else {
		Write-Host -Object ''
		$global:SQLSVCACCOUNT = Read-Host -Prompt 'Enter the Service Account("In Double Quotes")'
		Write-Host -Object ''
		$global:SQLSVCPASSWORD = Read-Host -Prompt 'Enter the Service Account Password ("In Double Quotes")'
		Write-Host -Object ''
	}
}


Function AdminAccountSQL {
	if ((Get-WmiObject Win32_ComputerSystem).Domain -eq "domain.com") {
		$global:SQLSYSADMINACCOUNTS = "CSSUMIT_DOMAIN\gSQLServerAdmins"
		#	write-host "Windows account(s) to provision as SQL Server system administrators("$SQLSYSADMINACCOUNTS")"     -ForegroundColor green
	}		
	elseif ((Get-WmiObject Win32_ComputerSystem).Domain -eq "domain_2.com") {
		$global:SQLSYSADMINACCOUNTS = "domain_2.com\gSQLServerAdmins"
		#write-host "Windows account(s) to provision as SQL Server system administrators("$SQLSYSADMINACCOUNTS")"     -ForegroundColor green
	}	
	else {
		$global:SQLSYSADMINACCOUNTS = Read-Host -Prompt 'Windows account(s) to provision as SQL Server system administrators ("DOMAIN_NAME\gSQLServerAdmins")'
	}
}

Function sqlVersion {
	$global:version = Read-Host -Prompt 'Enter the SQL Server Version(2014/2016/2017/2019)'
	if (($version -eq "2014") -or ($version -eq "2016") -or ($version -eq "2017") -or ($version -eq "2019") ) {
	}
	else {
		Write-Host -Object ''
		Write-Host "Please Enter a valid parameter for SQL Server Version. Possible options are: 2014, 2016, 2017,2019"   -ForegroundColor red
		Write-Host -Object ''
		pause
		sqlVersion
	}
}

Function CopyMedia {
	if ((Get-WmiObject Win32_ComputerSystem).Domain -eq "domain.com") {	
		$global:sqlEdition = Read-Host -Prompt 'Enter the SQL Server Edition (1=Enterprise,2=Standard[default])'
		Write-Host -Object ''
		if ($version -eq "2019") {
			if (($sqlEdition -eq "Enterprise") -or ($sqlEdition -eq "1")) {
				If (!(test-path C:\Downloads\MSSQL2019EntCore)) {
					New-Item -ItemType Directory -Force -Path C:\Downloads\MSSQL2019EntCore | Out-Null
				}
				If (!(test-path C:\Downloads\SQLUpdates)) {
					New-Item -ItemType Directory -Force -Path C:\Downloads\SQLUpdates | Out-Null
				}
				$global:MediaSource = "\\cs-softwarelocation\Software\MSSQL2019EntCore"
				$global:SQLBinariesLocation = "C:\Downloads\MSSQL2019EntCore"
				Write-Host -Object ''
				Write-Host -Object 'Copying MSSQL 2019 Enterprise Media to '  -ForegroundColor green -nonewline
				Write-Host -Object 'C:\Downloads\MSSQL2019EntCore'  -ForegroundColor yellow -nonewline
				Write-Host -Object ' Please Allow some time...  '  -ForegroundColor green
				robocopy $MediaSource $SQLBinariesLocation /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /XD "\\cs-softwarelocation\Software\MSSQL2019EntCore\ISO file - DO NOT COPY" /log:C:\temp\MediaCopy.log\
				Write-Host -Object ''
				Write-Host -Object 'Copying MSSQL 2019 Latest SQLUpdates to '  -ForegroundColor green -nonewline
				Write-Host -Object 'C:\Downloads\SQLUpdates'  -ForegroundColor yellow -nonewline
				Write-Host -Object ' Please Allow some time...  '  -ForegroundColor green
				robocopy "\\cs-softwarelocation.domain.com\software\MSSQL_All_Versions_SPs_CUs_ONLY\SQL Server 2019" "C:\Downloads\SQLUpdates" /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /log:C:\temp\SQLUpdates.log
				Write-Host -Object ''
				Write-Host -Object ''
				Write-Host -Object 'Media Copy Completed, Please Review Log Files...'  -ForegroundColor yellow
				Write-Host -Object ''
				Write-Host -Object ''
			}
			else {
				If (!(test-path C:\Downloads\MSSQL2019StdCore)) {
					New-Item -ItemType Directory -Force -Path C:\Downloads\MSSQL2019StdCore | Out-Null
				}
				$global:MediaSource = "\\cs-softwarelocation\Software\MSSQL2019StdCore"
				$global:SQLBinariesLocation = "C:\Downloads\MSSQL2019StdCore"
				Write-Host -Object ''
				Write-Host -Object 'Copying MSSQL 2019 Standard Media to '  -ForegroundColor green -nonewline
				Write-Host -Object 'C:\Downloads\MSSQL2019StdCore'  -ForegroundColor yellow -nonewline
				Write-Host -Object ' Please Allow some time...  '  -ForegroundColor green
				robocopy $MediaSource $SQLBinariesLocation /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /XD "\\cs-softwarelocation\Software\MSSQL2019StdCore\ISO file - DO NOT COPY" /log:C:\temp\MediaCopy.log
				Write-Host -Object ''
				Write-Host -Object 'Copying MSSQL 2019 Latest Updates to '  -ForegroundColor green -nonewline
				Write-Host -Object 'C:\Downloads\SQLUpdates'  -ForegroundColor yellow -nonewline
				Write-Host -Object ' Please Allow some time...  '  -ForegroundColor green
				robocopy "\\cs-softwarelocation.domain.com\software\MSSQL_All_Versions_SPs_CUs_ONLY\SQL Server 2019" "C:\Downloads\SQLUpdates" /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /log:C:\temp\SQLUpdates.log
				Write-Host -Object ''
				Write-Host -Object ''
				Write-Host -Object 'Media Copy Completed, Please Review Log Files...'  -ForegroundColor yellow
				Write-Host -Object ''
				Write-Host -Object ''		
			}
		}
					
		elseif ($version -eq "2017") {
			if (($sqlEdition -eq "Enterprise") -or ($sqlEdition -eq "1")) {
				If (!(test-path C:\Downloads\MSSQL2017EntCore)) {
					New-Item -ItemType Directory -Force -Path C:\Downloads\MSSQL2017EntCore | Out-Null
				}
				$global:MediaSource = "\\cs-softwarelocation\Software\MSSQL2017EntCore"
				$global:SQLBinariesLocation = "C:\Downloads\MSSQL2017EntCore"
				Write-Host -Object ''
				Write-Host -Object 'Copying MSSQL 2017 Enterprise Media to '  -ForegroundColor green -nonewline
				Write-Host -Object 'C:\Downloads\MSSQL2017EntCore'  -ForegroundColor yellow -nonewline
				Write-Host -Object ' Please Allow some time...  '  -ForegroundColor green
				robocopy $MediaSource $SQLBinariesLocation /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /XD "\\cs-softwarelocation\Software\MSSQL2017EntCore\ISO file - DO NOT COPY" /log:C:\temp\MediaCopy.log
				Write-Host -Object ''
				Write-Host -Object 'Copying MSSQL 2017 Latest Updates to '  -ForegroundColor green -nonewline
				Write-Host -Object 'C:\Downloads\SQLUpdates'  -ForegroundColor yellow -nonewline
				Write-Host -Object ' Please Allow some time...  '  -ForegroundColor green
				robocopy "\\cs-softwarelocation.domain.com\software\MSSQL_All_Versions_SPs_CUs_ONLY\SQL Server 2017" "C:\Downloads\SQLUpdates" /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /log:C:\temp\SQLUpdates.log
				Write-Host -Object ''
				Write-Host -Object ''
				Write-Host -Object 'Media Copy Completed, Please Review Log Files...'  -ForegroundColor yellow
				Write-Host -Object ''
			}
			else {
				If (!(test-path C:\Downloads\MSSQL2017StdCore)) {
					New-Item -ItemType Directory -Force -Path C:\Downloads\MSSQL2017StdCore | Out-Null
				}
				$global:MediaSource = "\\cs-softwarelocation\Software\MSSQL2017StdCore"
				$global:SQLBinariesLocation = "C:\Downloads\MSSQL2017StdCore"
				Write-Host -Object ''
				Write-Host -Object 'Copying MSSQL 2017 Standard Media to '  -ForegroundColor green -nonewline
				Write-Host -Object 'C:\Downloads\MSSQL2017StdCore'  -ForegroundColor yellow -nonewline
				Write-Host -Object ', Please Allow some time...  '  -ForegroundColor green
				robocopy $MediaSource $SQLBinariesLocation /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /XD "\\cs-softwarelocation\Software\MSSQL2017StdCore\ISO file - DO NOT COPY" /log:C:\temp\MediaCopy.log
				Write-Host -Object ''
				Write-Host -Object 'Copying MSSQL 2017 Latest Updates to '  -ForegroundColor green -nonewline
				Write-Host -Object 'C:\Downloads\SQLUpdates'  -ForegroundColor yellow -nonewline
				Write-Host -Object ' Please Allow some time...  '  -ForegroundColor green
				robocopy "\\cs-softwarelocation.domain.com\software\MSSQL_All_Versions_SPs_CUs_ONLY\SQL Server 2017" "C:\Downloads\SQLUpdates" /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /log:C:\temp\SQLUpdates.log
				Write-Host -Object ''
				Write-Host -Object ''
				Write-Host -Object 'Media Copy Completed, Please Review Log Files...'  -ForegroundColor yellow
				Write-Host -Object ''
			}
		}
					
		elseif ($version -eq "2016") {
			if (($sqlEdition -eq "Enterprise") -or ($sqlEdition -eq "1")) {
				If (!(test-path C:\Downloads\MSSQL2016EntCore)) {
					New-Item -ItemType Directory -Force -Path C:\Downloads\MSSQL2016EntCore | Out-Null
				}
				$global:MediaSource = "\\cs-softwarelocation\Software\MSSQL2016EntCore"
				#Skip files: DistributionVersionDONOTCOPY and ISO file DO NOT COPY THIS FOLDER
				$global:SQLBinariesLocation = "C:\Downloads\MSSQL2016EntCore"
				Write-Host -Object ''
				Write-Host -Object 'Copying MSSQL 2016 Enterprise Media to '  -ForegroundColor green -nonewline
				Write-Host -Object 'C:\Downloads\MSSQL2016EntCore'  -ForegroundColor yellow -nonewline
				Write-Host -Object ' Please Allow some time...  '  -ForegroundColor green
				robocopy $MediaSource $SQLBinariesLocation /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /XD "\\cs-softwarelocation\Software\MSSQL2016EntCore\ISO file DO NOT COPY THIS FOLDER" "\\cs-softwarelocation\Software\MSSQL2016EntCore\DistributionVersionDONOTCOPY" "\\cs-softwarelocation\Software\MSSQL2016EntCore\AW2016" /log:C:\temp\MediaCopy.log
				Write-Host -Object ''
				Write-Host -Object 'Copying MSSQL 2016 Latest Updates to '  -ForegroundColor green -nonewline
				Write-Host -Object 'C:\Downloads\SQLUpdates'  -ForegroundColor yellow -nonewline
				Write-Host -Object ' Please Allow some time...  '  -ForegroundColor green
				robocopy "\\cs-softwarelocation.domain.com\software\MSSQL_All_Versions_SPs_CUs_ONLY\SQL Server 2016\SP2" "C:\Downloads\SQLUpdates" /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /log:C:\temp\SQLUpdates.log
				Write-Host -Object ''
				Write-Host -Object ''
				Write-Host -Object 'Media Copy Completed, Please Review Log Files...'  -ForegroundColor yellow
				Write-Host -Object ''
			}
			else {
				If (!(test-path C:\Downloads\MSSQL2016Std)) {
					New-Item -ItemType Directory -Force -Path C:\Downloads\MSSQL2016Std | Out-Null
				}
				$global:MediaSource = "\\cs-softwarelocation\Software\MSSQL2016Std"
				$global:SQLBinariesLocation = "C:\Downloads\MSSQL2016Std"
				Write-Host -Object ''
				Write-Host -Object 'Copying MSSQL 2016 Standard Media to '  -ForegroundColor green -nonewline
				Write-Host -Object 'C:\Downloads\MSSQL2016Std'  -ForegroundColor yellow -nonewline
				Write-Host -Object ' Please Allow some time...  '  -ForegroundColor green
				robocopy $MediaSource $SQLBinariesLocation /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /XD "\\cs-softwarelocation\Software\MSSQL2016Std\ISO file - DO NOT COPY" /log:C:\temp\MediaCopy.log
				Write-Host -Object ''
				Write-Host -Object 'Copying MSSQL 2016 Latest Updates to '  -ForegroundColor green -nonewline
				Write-Host -Object 'C:\Downloads\SQLUpdates'  -ForegroundColor yellow -nonewline
				Write-Host -Object ' Please Allow some time...  '  -ForegroundColor green
				robocopy "\\cs-softwarelocation.domain.com\software\MSSQL_All_Versions_SPs_CUs_ONLY\SQL Server 2016\SP2" "C:\Downloads\SQLUpdates" /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /log:C:\temp\SQLUpdates.log
				Write-Host -Object ''
				Write-Host -Object ''
				Write-Host -Object 'Media Copy Completed, Please Review Log Files...'  -ForegroundColor yellow
				Write-Host -Object ''
			}
		}
						
		elseif ($version -eq "2014") {
			if (($sqlEdition -eq "Enterprise") -or ($sqlEdition -eq "1")) {
				If (!(test-path C:\Downloads\MSSQL2014EntCore)) {
					New-Item -ItemType Directory -Force -Path C:\Downloads\MSSQL2014EntCore | Out-Null
				}
				$global:MediaSource = "\\cs-softwarelocation.domain.com\software\MSSQL2014EntCore\64-Bit"
				$global:SQLBinariesLocation = "C:\Downloads\MSSQL2014EntCore"
				Write-Host -Object ''
				Write-Host -Object 'Copying MSSQL 2014 Enterprise Media to '  -ForegroundColor green -nonewline
				Write-Host -Object 'C:\Downloads\MSSQL2014EntCore'  -ForegroundColor yellow -nonewline
				Write-Host -Object ' Please Allow some time...  '  -ForegroundColor green
				robocopy $MediaSource $SQLBinariesLocation /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /log:C:\temp\MediaCopy.log
				Write-Host -Object ''
				Write-Host -Object 'Copying MSSQL 2014 Latest Updates to '  -ForegroundColor green -nonewline
				Write-Host -Object 'C:\Downloads\SQLUpdates'  -ForegroundColor yellow -nonewline
				Write-Host -Object ' Please Allow some time...  '  -ForegroundColor green
				robocopy "\\cs-softwarelocation.domain.com\software\MSSQL_All_Versions_SPs_CUs_ONLY\SQL Server 2014\SP3" "C:\Downloads\SQLUpdates" /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /log:C:\temp\SQLUpdates.log
				Write-Host -Object ''
				Write-Host -Object ''
				Write-Host -Object 'Media Copy Completed, Please Review Log Files...'  -ForegroundColor yellow
				Write-Host -Object ''
			}
			else {
				If (!(test-path C:\Downloads\MSSQL2014Std)) {
					New-Item -ItemType Directory -Force -Path C:\Downloads\MSSQL2014Std | Out-Null
				}
				$global:MediaSource = "\\cs-softwarelocation.domain.com\software\MSSQL2014Std"
				$global:SQLBinariesLocation = "C:\Downloads\MSSQL2014Std"
				Write-Host -Object ''
				Write-Host -Object 'Copying MSSQL 2014 Standard Media to '  -ForegroundColor green -nonewline
				Write-Host -Object 'C:\Downloads\MSSQL2014Std'  -ForegroundColor yellow -nonewline
				Write-Host -Object ' Please Allow some time...  '  -ForegroundColor green
				robocopy $MediaSource $SQLBinariesLocation /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /XD "\\cs-softwarelocation\Software\MSSQL2014Std\ISO" /log:C:\temp\MediaCopy.log
				Write-Host -Object ''
				Write-Host -Object 'Copying MSSQL 2014 Latest Updates to '  -ForegroundColor green -nonewline
				Write-Host -Object 'C:\Downloads\SQLUpdates'  -ForegroundColor yellow -nonewline
				Write-Host -Object ' Please Allow some time...  '  -ForegroundColor green
				robocopy "\\cs-softwarelocation.domain.com\software\MSSQL_All_Versions_SPs_CUs_ONLY\SQL Server 2014\SP3" "C:\Downloads\SQLUpdates" /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /log:C:\temp\SQLUpdates.log
				Write-Host -Object ''
				Write-Host -Object ''
				Write-Host -Object 'Media Copy Completed, Please Review Log Files...'  -ForegroundColor yellow
				Write-Host -Object ''
			}
		}
		else {
			Write-Host -Object ''
			Write-Host "Please Enter a valid parameter for SQL Server Version and Edition."   -ForegroundColor red
			Write-Host -Object ''
		}
	}

	elseif ((Get-WmiObject Win32_ComputerSystem).Domain -eq "domain_2.com") {
		$global:sqlEdition = Read-Host -Prompt 'Enter the SQL Server Edition (1=Enterprise,2=Standard[default])'
		Write-Host -Object ''
		if ($version -eq "2019") {
			if (($sqlEdition -eq "Enterprise") -or ($sqlEdition -eq "1")) {
				If (!(test-path C:\Downloads\MSSQL2019EntCore)) {
					New-Item -ItemType Directory -Force -Path C:\Downloads\MSSQL2019EntCore | Out-Null
				}
				$global:MediaSource = "\\cs-softwarelocation\Microsoft\SQL\InstallMedia\SQL2019\Enterprise"
				$global:SQLBinariesLocation = "C:\Downloads\MSSQL2019EntCore"
				Write-Host -Object ''
				Write-Host -Object 'Copying MSSQL 2019 Enterprise Media to '  -ForegroundColor green -nonewline
				Write-Host -Object 'C:\Downloads\MSSQL2019EntCore'  -ForegroundColor yellow -nonewline
				Write-Host -Object ' Please Allow some time...  '  -ForegroundColor green
				robocopy $MediaSource $SQLBinariesLocation /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /log:C:\temp\MediaCopy.log
				Write-Host -Object ''
				Write-Host -Object 'Copying MSSQL 2019 Latest Updates to '  -ForegroundColor green -nonewline
				Write-Host -Object 'C:\Downloads\SQLUpdates'  -ForegroundColor yellow -nonewline
				Write-Host -Object ' Please Allow some time...  '  -ForegroundColor green
				robocopy "\\cs-softwarelocation\ASPSQL_CSM\MSSQL_All_Versions_SPs_CUs_ONLY\SQL Server 2019" "C:\Downloads\SQLUpdates" /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /log:C:\temp\SQLUpdates.log
				Write-Host -Object ''
				Write-Host -Object ''
				Write-Host -Object 'Media Copy Completed, Please Review Log Files...'  -ForegroundColor yellow
				Write-Host -Object ''
				Write-Host -Object ''
			}
			else {
				If (!(test-path C:\Downloads\MSSQL2019StdCore)) {
					New-Item -ItemType Directory -Force -Path C:\Downloads\MSSQL2019StdCore | Out-Null
				}
				$global:MediaSource = "\\cs-softwarelocation\Microsoft\SQL\InstallMedia\SQL2019\Standard"
				$global:SQLBinariesLocation = "C:\Downloads\MSSQL2019StdCore"
				Write-Host -Object ''
				Write-Host -Object 'Copying MSSQL 2019 Standard Media to '  -ForegroundColor green -nonewline
				Write-Host -Object 'C:\Downloads\MSSQL2019StdCore'  -ForegroundColor yellow -nonewline
				Write-Host -Object ' Please Allow some time...  '  -ForegroundColor green
				robocopy $MediaSource $SQLBinariesLocation /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /log:C:\temp\MediaCopy.log
				Write-Host -Object ''
				Write-Host -Object 'Copying MSSQL 2019 Latest Updates to '  -ForegroundColor green -nonewline
				Write-Host -Object 'C:\Downloads\SQLUpdates'  -ForegroundColor yellow -nonewline
				Write-Host -Object ' Please Allow some time...  '  -ForegroundColor green
				robocopy "\\cs-softwarelocation\ASPSQL_CSM\MSSQL_All_Versions_SPs_CUs_ONLY\SQL Server 2019" "C:\Downloads\SQLUpdates" /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /log:C:\temp\SQLUpdates.log
				Write-Host -Object ''
				Write-Host -Object ''
				Write-Host -Object 'Media Copy Completed, Please Review Log Files...'  -ForegroundColor yellow
				Write-Host -Object ''
				Write-Host -Object ''		
			}
		}
		elseif ($version -eq "2017") {
			if (($sqlEdition -eq "Enterprise") -or ($sqlEdition -eq "1")) {
				If (!(test-path C:\Downloads\MSSQL2017EntCore)) {
					New-Item -ItemType Directory -Force -Path C:\Downloads\MSSQL2017EntCore | Out-Null
				}
				$global:MediaSource = "\\cs-softwarelocation\Microsoft\SQL\InstallMedia\SQL2017\Enterprise"
				$global:SQLBinariesLocation = "C:\Downloads\MSSQL2017EntCore"
				Write-Host -Object ''
				Write-Host -Object 'Copying MSSQL 2017 Enterprise Media to '  -ForegroundColor green -nonewline
				Write-Host -Object 'C:\Downloads\MSSQL2017EntCore'  -ForegroundColor yellow -nonewline
				Write-Host -Object ' Please Allow some time...  '  -ForegroundColor green
				robocopy $MediaSource $SQLBinariesLocation /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /log:C:\temp\MediaCopy.log
				Write-Host -Object ''
				Write-Host -Object 'Copying MSSQL 2017 Latest Updates to '  -ForegroundColor green -nonewline
				Write-Host -Object 'C:\Downloads\SQLUpdates'  -ForegroundColor yellow -nonewline
				Write-Host -Object ' Please Allow some time...  '  -ForegroundColor gree
				robocopy "\\cs-softwarelocation\ASPSQL_CSM\MSSQL_All_Versions_SPs_CUs_ONLY\SQL Server 2017" "C:\Downloads\SQLUpdates" /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /log:C:\temp\SQLUpdates.log
				Write-Host -Object ''
				Write-Host -Object ''
				Write-Host -Object 'Media Copy Completed, Please Review Log Files...'  -ForegroundColor yellow
				Write-Host -Object ''
			}
			else {
				If (!(test-path C:\Downloads\MSSQL2017StdCore)) {
					New-Item -ItemType Directory -Force -Path C:\Downloads\MSSQL2017StdCore | Out-Null
				}
				$global:MediaSource = "\\cs-softwarelocation\Microsoft\SQL\InstallMedia\SQL2017\Standard"
				$global:SQLBinariesLocation = "C:\Downloads\MSSQL2017StdCore"
				Write-Host -Object ''
				Write-Host -Object 'Copying MSSQL 2017 Standard Media to '  -ForegroundColor green -nonewline
				Write-Host -Object 'C:\Downloads\MSSQL2017StdCore'  -ForegroundColor yellow -nonewline
				Write-Host -Object ', Please Allow some time...  '  -ForegroundColor green
				robocopy $MediaSource $SQLBinariesLocation /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /log:C:\temp\MediaCopy.log
				Write-Host -Object ''
				Write-Host -Object 'Copying MSSQL 2017 Latest Updates to '  -ForegroundColor green -nonewline
				Write-Host -Object 'C:\Downloads\SQLUpdates'  -ForegroundColor yellow -nonewline
				Write-Host -Object ' Please Allow some time...  '  -ForegroundColor gree
				robocopy "\\cs-softwarelocation\ASPSQL_CSM\MSSQL_All_Versions_SPs_CUs_ONLY\SQL Server 2017" "C:\Downloads\SQLUpdates" /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /log:C:\temp\SQLUpdates.log
				Write-Host -Object ''
				Write-Host -Object ''
				Write-Host -Object 'Media Copy Completed, Please Review Log Files...'  -ForegroundColor yellow
				Write-Host -Object ''
			}
		}
		elseif ($version -eq "2016") {
			if (($sqlEdition -eq "Enterprise") -or ($sqlEdition -eq "1")) {
				If (!(test-path C:\Downloads\MSSQL2016EntCore)) {
					New-Item -ItemType Directory -Force -Path C:\Downloads\MSSQL2016EntCore | Out-Null
				}
				$global:MediaSource = "\\cs-softwarelocation\Microsoft\SQL\InstallMedia\SQL2016\Enterprise"
				#Skip files: DistributionVersionDONOTCOPY and ISO file DO NOT COPY THIS FOLDER
				$global:SQLBinariesLocation = "C:\Downloads\MSSQL2016EntCore"
				Write-Host -Object ''
				Write-Host -Object 'Copying MSSQL 2016 Enterprise Media to '  -ForegroundColor green -nonewline
				Write-Host -Object 'C:\Downloads\MSSQL2016EntCore'  -ForegroundColor yellow -nonewline
				Write-Host -Object ' Please Allow some time...  '  -ForegroundColor green
				robocopy $MediaSource $SQLBinariesLocation /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /log:C:\temp\MediaCopy.log
				Write-Host -Object ''
				Write-Host -Object 'Copying MSSQL 2016 Latest Updates to '  -ForegroundColor green -nonewline
				Write-Host -Object 'C:\Downloads\SQLUpdates'  -ForegroundColor yellow -nonewline
				Write-Host -Object ' Please Allow some time...  '  -ForegroundColor gree
				robocopy "\\cs-softwarelocation\ASPSQL_CSM\MSSQL_All_Versions_SPs_CUs_ONLY\SQL Server 2016" "C:\Downloads\SQLUpdates" /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /log:C:\temp\SQLUpdates.log
				Write-Host -Object ''
				Write-Host -Object ''
				Write-Host -Object 'Media Copy Completed, Please Review Log Files...'  -ForegroundColor yellow
				Write-Host -Object ''
			}
			else {
				If (!(test-path C:\Downloads\MSSQL2016Std)) {
					New-Item -ItemType Directory -Force -Path C:\Downloads\MSSQL2016Std | Out-Null
				}
				$global:MediaSource = "\\cs-softwarelocation\Microsoft\SQL\InstallMedia\SQL2016\Standard"
				$global:SQLBinariesLocation = "C:\Downloads\MSSQL2016Std"
				Write-Host -Object ''
				Write-Host -Object 'Copying MSSQL 2016 Standard Media to '  -ForegroundColor green -nonewline
				Write-Host -Object 'C:\Downloads\MSSQL2016Std'  -ForegroundColor yellow -nonewline
				Write-Host -Object ' Please Allow some time...  '  -ForegroundColor green
				robocopy $MediaSource $SQLBinariesLocation /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /log:C:\temp\MediaCopy.log
				Write-Host -Object ''
				Write-Host -Object 'Copying MSSQL 2016 Latest Updates to '  -ForegroundColor green -nonewline
				Write-Host -Object 'C:\Downloads\SQLUpdates'  -ForegroundColor yellow -nonewline
				Write-Host -Object ' Please Allow some time...  '  -ForegroundColor gree
				robocopy "\\cs-softwarelocation\ASPSQL_CSM\MSSQL_All_Versions_SPs_CUs_ONLY\SQL Server 2016" "C:\Downloads\SQLUpdates" /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /log:C:\temp\SQLUpdates.log
				Write-Host -Object ''
				Write-Host -Object ''
				Write-Host -Object 'Media Copy Completed, Please Review Log Files...'  -ForegroundColor yellow
				Write-Host -Object ''
			}
		}
		elseif ($version -eq "2014") {
			if (($sqlEdition -eq "Enterprise") -or ($sqlEdition -eq "1")) {
				If (!(test-path C:\Downloads\MSSQL2014EntCore)) {
					New-Item -ItemType Directory -Force -Path C:\Downloads\MSSQL2014EntCore | Out-Null
				}
				$global:MediaSource = "\\cs-softwarelocation\Microsoft\SQL\InstallMedia\SQL2014\Enterprise"
				$global:SQLBinariesLocation = "C:\Downloads\MSSQL2014EntCore"
				Write-Host -Object ''
				Write-Host -Object 'Copying MSSQL 2014 Enterprise Media to '  -ForegroundColor green -nonewline
				Write-Host -Object 'C:\Downloads\MSSQL2014EntCore'  -ForegroundColor yellow -nonewline
				Write-Host -Object ' Please Allow some time...  '  -ForegroundColor green
				robocopy $MediaSource $SQLBinariesLocation /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /log:C:\temp\MediaCopy.log
				Write-Host -Object ''
				Write-Host -Object 'Copying MSSQL 2014 Latest Updates to '  -ForegroundColor green -nonewline
				Write-Host -Object 'C:\Downloads\SQLUpdates'  -ForegroundColor yellow -nonewline
				Write-Host -Object ' Please Allow some time...  '  -ForegroundColor gree
				robocopy "\\cs-softwarelocation\ASPSQL_CSM\MSSQL_All_Versions_SPs_CUs_ONLY\SQL Server 2014" "C:\Downloads\SQLUpdates" /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /log:C:\temp\SQLUpdates.log
				Write-Host -Object ''
				Write-Host -Object ''
				Write-Host -Object 'Media Copy Completed, Please Review Log Files...'  -ForegroundColor yellow
				Write-Host -Object ''
			}
			else {
				If (!(test-path C:\Downloads\MSSQL2014Std)) {
					New-Item -ItemType Directory -Force -Path C:\Downloads\MSSQL2014Std | Out-Null
				}
				$global:MediaSource = "\\cs-softwarelocation\Microsoft\SQL\InstallMedia\SQL2014\Standard"
				$global:SQLBinariesLocation = "C:\Downloads\MSSQL2014Std"
				Write-Host -Object ''
				Write-Host -Object 'Copying MSSQL 2014 Standard Media to '  -ForegroundColor green -nonewline
				Write-Host -Object 'C:\Downloads\MSSQL2014Std'  -ForegroundColor yellow -nonewline
				Write-Host -Object ' Please Allow some time...  '  -ForegroundColor green
				robocopy $MediaSource $SQLBinariesLocation /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /log:C:\temp\MediaCopy.log
				Write-Host -Object ''
				Write-Host -Object 'Copying MSSQL 2014 Latest Updates to '  -ForegroundColor green -nonewline
				Write-Host -Object 'C:\Downloads\SQLUpdates'  -ForegroundColor yellow -nonewline
				Write-Host -Object ' Please Allow some time...  '  -ForegroundColor gree
				robocopy "\\cs-softwarelocation\ASPSQL_CSM\MSSQL_All_Versions_SPs_CUs_ONLY\SQL Server 2014" "C:\Downloads\SQLUpdates" /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /log:C:\temp\SQLUpdates.log
				Write-Host -Object ''
				Write-Host -Object ''
				Write-Host -Object 'Media Copy Completed, Please Review Log Files...'  -ForegroundColor yellow
				Write-Host -Object ''
			}
		}
		else {
			Write-Host -Object ''
			Write-Host "Please Enter a valid parameter for SQL Server Version and Edition."   -ForegroundColor red
			Write-Host -Object ''
		}
	}
	else {
		$global:MediaSource = Read-Host -Prompt 'Enter the Source Path of SQL Server Binaries'
		$global:SQLBinariesLocation = Read-Host -Prompt 'Enter the Destination Path for SQL Server Binaries'
		Write-Host -Object ''
		$setupfilepath = "$SQLBinariesLocation\setup.exe"
		if ((($SQLBinariesLocation | Measure-Object).count -eq 0) -or ($SQLBinariesLocation -eq "")) {
			Write-Host -Object ''
			Write-Host "Please Enter a valid Destination path of SQL Server Media"    -ForegroundColor yellow
			Write-Host -Object ''
			pause
			CopyMedia
		}
		#elseif((test-path $SQLBinariesLocation))
		#{
		#}
		elseif ((Test-Path $setupfilepath)) {
			Write-Host -Object ''
			Write-Host "SQL Server Media found, proceeding further..."  -ForegroundColor green
			Write-Host -Object ''
		}

		elseif (($MediaSource -ne "") -and ($SQLBinariesLocation -ne "")) {
			Write-Host -Object ''
			Write-Host -Object 'Copying Media Files, Please Allow some time...  '  -ForegroundColor green
			robocopy $MediaSource $SQLBinariesLocation /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /log:C:\temp\MediaCopy.log
			Write-Host -Object ''
			Write-Host -Object ''
			Write-Host -Object 'Media Copy Completed, Please Review Log Files...'  -ForegroundColor yellow
		}

		else {
			Write-Host -Object ''
			Write-Host "Please Enter a valid Source and Destination path of SQL Server Media"  -ForegroundColor yellow
			Write-Host -Object ''
			pause
			CopyMedia
		}
	}
}

Function zabbixConfiguration {
	if ((Get-WmiObject Win32_ComputerSystem).Domain -eq "domain.com") {
		If (!(test-path C:\zabbix)) {
			New-Item -ItemType Directory -Force -Path C:\zabbix | Out-Null
		}
		Write-Host -Object ''
		write-host "LOcal Node Zabbix Configuration!!"     -ForegroundColor green
		Write-Host -Object ''
		write-host "Copying the zabbix files..."     -ForegroundColor yellow
		Start-Sleep -Seconds 2
		robocopy \\cssumitwhq4\CSMDBA\DB\SQLInstall\zabbix C:\ /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /log:C:\temp\LocalZabbixCopy.log
		Write-Host -Object ''
		Write-Host -Object ''
		Write-Host -Object 'Zabbix Files Copied to Local host, please review Zabbix(C:\Zabbix) and log file(C:\temp\LocalZabbixCopy.log) and hit Enter to Configure and install Zabbix'  -ForegroundColor green
		Write-Host -Object ''
		pause
		If ((test-path c:\zabbix\bin\zabbix_agentd.exe) -or (test-path C:\zabbix\conf\zabbix_agentd.conf)) {
			#Install zabbix agent as a windows service run:
			c:\zabbix\bin\zabbix_agentd.exe --config c:\zabbix\conf\zabbix_agentd.conf --install
			#Now you can use Control Panel to start agent's service or run:
			c:\zabbix\bin\zabbix_agentd.exe --config c:\zabbix\conf\zabbix_agentd.conf --start
			if (Get-Service "Zabbix Agent" | Where-Object { $_.Status -EQ "Running" }) {
				#Write-Host -Object ''
				#Get-Service "Zabbix Agent"| Where-Object {$_.Status -EQ "Running"}
				Write-Host -Object ''
				write-host "Local Zabbix Agent is Configured Successfully!! Please login to Zabbix console and add proper templates."     -ForegroundColor green
			}
			else {
				Write-Host -Object ''
				write-host "Zabbix Agent is not Configured properly, Please validate the service status manaully."     -ForegroundColor yellow
				pause
				sqlPostInstallation
			}
					
			Write-Host -Object ''
			Write-Host -Object ''
			write-host "Please hit Enter to Continue "     -ForegroundColor yellow -NoNewline
			write-host "Cluster Zabbix Configuration"     -ForegroundColor green
			Write-Host -Object ''
			
			#Cluster Zabbix Configuration
			Write-Host -Object ''
			write-host "Cluster Zabbix Configuration!!"     -ForegroundColor green
			Write-Host -Object ''
			write-host "Copying the Cluster Zabbix files..."     -ForegroundColor yellow
			Start-Sleep -Seconds 2
			robocopy \\cssumitwhq4\CSMDBA\DB\SQLInstall\ClusterGroup1 C:\zabbix /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /log:C:\temp\ClusterZabbixCopy.log
			Write-Host -Object ''
			Write-Host -Object 'Cluster Zabbix Files Copied to Local host, please review Zabbix(C:\zabbix\ClusterGroup1) and log file(C:\temp\ClusterZabbixCopy.log) and hit Enter to Configure and install Zabbix'  -ForegroundColor green
			Write-Host -Object ''
			write-host "Adding Instance Name and IP Entries to Configuration File - zabbix_agentd.conf"     -ForegroundColor yellow
			Start-Sleep -Seconds 2
			$global:FAILOVERCLUSTERNETWORKNAME = Get-ClusterResource -Name "SQL Server" | Get-ClusterParameter -Name "VirtualServerName" | select -ExpandProperty Value
			$global:SQLIP = Get-ClusterResource -Name "SQL IP*" | Get-ClusterParameter -Name "Address" | Select-Object -ExpandProperty Value
			Add-Content -Path "C:\zabbix\ClusterGroup1\zabbix_agentd.conf" -Value "Hostname=$FAILOVERCLUSTERNETWORKNAME"
			Add-Content -Path "C:\zabbix\ClusterGroup1\zabbix_agentd.conf" -Value "ListenIP=$SQLIP"
			Write-Host -Object ''
			write-host "Creating Cluster Zabbix agent Service..."     -ForegroundColor yellow
			Write-Host -Object ''
			$params = @{
				Name           = "ZABBIX Agent ($FAILOVERCLUSTERNETWORKNAME)"
				BinaryPathName = '"C:\zabbix\ClusterGroup1\zabbix_agentd.exe" --config "C:\zabbix\ClusterGroup1\zabbix_agentd.conf"'
				DisplayName    = "ZABBIX Agent ($FAILOVERCLUSTERNETWORKNAME)"
				StartupType    = "Manual"
				Description    = "Cluster Zabbix Agent For SQL Server"
			}
			New-Service @params
			if (get-service -Name "ZABBIX Agent ($FAILOVERCLUSTERNETWORKNAME)") {
				Write-Host -Object ''
				write-host "Cluster Zabbix agent Service Creation Successful."     -ForegroundColor green
				Write-Host -Object ''
			}
			else {
				Write-Host -Object ''
				write-host "Cluster Zabbix agent creation failed, please review the error logs."     -ForegroundColor red
				Write-Host -Object ''
				sqlPostInstallation
			}
			#Validate Active Node in Cluster, to Add Generic Service
			$DBSERVER = [System.Net.Dns]::GetHostName()
			$ClusterOwner = (get-clustergroup -Name 'SQL Server (MSSQLSERVER)').ownernode.name
			if (($ClusterOwner -eq $DBSERVER)) {
				Write-Host -Object ''
				write-host "Adding Cluster ZABBIX Agent to the cluster Resources."     -ForegroundColor yellow
				Write-Host -Object ''
				Add-ClusterResource -Name "ZABBIX Agent ($FAILOVERCLUSTERNETWORKNAME)" -Group "SQL Server (MSSQLSERVER)" -ResourceType "Generic Service" | Set-ClusterParameter -Name ServiceName -Value "ZABBIX Agent ($FAILOVERCLUSTERNETWORKNAME)" 
				Get-ClusterResource -Name "ZABBIX Agent ($FAILOVERCLUSTERNETWORKNAME)" | Set-ClusterParameter -Name StartupParameters -value ' --config "C:\zabbix\ClusterGroup1\zabbix_agentd.conf"' 
				Start-ClusterResource -Name "ZABBIX Agent ($FAILOVERCLUSTERNETWORKNAME)"
				$SQLIPAddress = Get-ClusterResource -name "SQL IP Address*" | Select-Object -ExpandProperty Name
				Get-ClusterResource -name "ZABBIX Agent ($FAILOVERCLUSTERNETWORKNAME)" | Add-ClusterResourceDependency -Provider "$SQLIPAddress"
			}
			if (Get-ClusterResource -Name "ZABBIX Agent ($FAILOVERCLUSTERNETWORKNAME)") {
				Write-Host -Object ''
				write-host "Cluster Zabbix Agent is Configured Successfully!! Please review Status on Active node and add proper templates in zabbix console. "     -ForegroundColor green
				Write-Host -Object ''
				Write-Host -Object ''
				pause
				sqlPostInstallation
			}
			else {
				Write-Host -Object ''
				write-host "Cluster ZABBIX Agent failed to add as cluster Resources. Please review and validate the service status manaully."     -ForegroundColor red
				Write-Host -Object ''
				Write-Host -Object ''
				pause
				sqlPostInstallation
			}                   
		}
		else {
			Write-Host -Object ''
			write-host "Zabbix files are not copied!!! Please validate the Destination path(C:\Zabbix) and LocalZabbixCopy.log"     -ForegroundColor yellow
			pause
			sqlPostInstallation
		}
	}

	elseif ((Get-WmiObject Win32_ComputerSystem).Domain -eq "domain_2.com") {
		If (!(test-path C:\zabbix)) {
			New-Item -ItemType Directory -Force -Path C:\zabbix | Out-Null
		}
		Write-Host -Object ''
		write-host "Copying the zabbix files..."     -ForegroundColor green
		robocopy \\cs-softwarelocation\ASPSQL_CSM\SQLInstall\zabbix C:\ /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /log:C:\temp\LocalZabbixCopy.log
		Write-Host -Object ''
		Write-Host -Object 'Zabbix Files Copied to Local host, please review Zabbix(C:\Zabbix) and log file(C:\temp\LocalZabbixCopy.log) and hit Enter to Configure and install Zabbix'  -ForegroundColor green
		pause
				
		If ((test-path c:\zabbix\bin\zabbix_agentd.exe) -or (test-path C:\zabbix\conf\zabbix_agentd.conf)) {
			#Install zabbix agent as a windows service run:
			c:\zabbix\bin\zabbix_agentd.exe --config c:\zabbix\conf\zabbix_agentd.conf --install
			#Now you can use Control Panel to start agent's service or run:
			c:\zabbix\bin\zabbix_agentd.exe --config c:\zabbix\conf\zabbix_agentd.conf --start
			if (Get-Service "Zabbix Agent" | Where-Object { $_.Status -EQ "Running" }) {
				#Write-Host -Object ''
				#Get-Service "Zabbix Agent"| Where-Object {$_.Status -EQ "Running"}
				Write-Host -Object ''
				write-host "Zabbix Agent is Configured Successfully!! Please login to Zabbix console and add proper templates."     -ForegroundColor green
				Write-Host -Object ''
				pause
				}
			else {
				Write-Host -Object ''
				write-host "Zabbix Agent is not Configured properly, Please validate the service status manaully."     -ForegroundColor yellow
				pause
				sqlPostInstallation
			}

			#Cluster Zabbix Configuration
			Write-Host -Object ''
			write-host "Cluster Zabbix Configuration!!"     -ForegroundColor green
			Write-Host -Object ''
			write-host "Copying the Cluster Zabbix files..."     -ForegroundColor yellow
			Start-Sleep -Seconds 2
			robocopy \\cs-softwarelocation\ASPSQL_CSM\SQLInstall\ClusterGroup1 C:\zabbix /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /log:C:\temp\ClusterZabbixCopy.log
			Write-Host -Object ''
			Write-Host -Object 'Cluster Zabbix Files Copied to Local host, please review Zabbix(C:\zabbix\ClusterGroup1) and log file(C:\temp\ClusterZabbixCopy.log) and hit Enter to Configure and install Zabbix'  -ForegroundColor yellow
			Write-Host -Object ''
			write-host "Adding Instance Name and IP Entries to Configuration File - zabbix_agentd.conf"     -ForegroundColor yellow
			Start-Sleep -Seconds 2
			$global:FAILOVERCLUSTERNETWORKNAME = Get-ClusterResource -Name "SQL Server" | Get-ClusterParameter -Name "VirtualServerName" | Select-Object -ExpandProperty Value
			$global:SQLIP = Get-ClusterResource -Name "SQL IP*" | Get-ClusterParameter -Name "Address" | Select-Object -ExpandProperty Value
			Add-Content -Path "C:\zabbix\ClusterGroup1\zabbix_agentd.conf" -Value "Hostname=$FAILOVERCLUSTERNETWORKNAME"
			Add-Content -Path "C:\zabbix\ClusterGroup1\zabbix_agentd.conf" -Value "ListenIP=$SQLIP"
			Write-Host -Object ''
			write-host "Creating Cluster Zabbix agent Service..."     -ForegroundColor yellow
			Write-Host -Object ''
						
			$params = @{
				Name           = "ZABBIX Agent ($FAILOVERCLUSTERNETWORKNAME)"
				BinaryPathName = '"C:\zabbix\ClusterGroup1\zabbix_agentd.exe" --config "C:\zabbix\ClusterGroup1\zabbix_agentd.conf"'
				DisplayName    = "ZABBIX Agent ($FAILOVERCLUSTERNETWORKNAME)"
				StartupType    = "Manual"
				Description    = "Cluster Zabbix Agent For SQL Server"
			}
			New-Service @params
			if (get-service -Name "ZABBIX Agent ($FAILOVERCLUSTERNETWORKNAME)") {
				Write-Host -Object ''
				write-host "Cluster Zabbix agent Service Creation Successful."     -ForegroundColor green
				Write-Host -Object ''
			}
			else {
				Write-Host -Object ''
				write-host "Cluster Zabbix agent creation failed, please review the error logs."     -ForegroundColor red
				Write-Host -Object ''
				sqlPostInstallation
			}
			#Validate Active Node in Cluster, to Add Generic Service
			$DBSERVER = [System.Net.Dns]::GetHostName()
			$ClusterOwner = (get-clustergroup -Name 'SQL Server (MSSQLSERVER)').ownernode.name
			if (($ClusterOwner -eq $DBSERVER)) {
				Write-Host -Object ''
				write-host "Adding Cluster ZABBIX Agent to the cluster Resources."     -ForegroundColor yellow
				Write-Host -Object ''
				Add-ClusterResource -Name "ZABBIX Agent ($FAILOVERCLUSTERNETWORKNAME)" -Group "SQL Server (MSSQLSERVER)" -ResourceType "Generic Service" | Set-ClusterParameter -Name ServiceName -Value "ZABBIX Agent ($FAILOVERCLUSTERNETWORKNAME)" 
				Get-ClusterResource -Name "ZABBIX Agent ($FAILOVERCLUSTERNETWORKNAME)" | Set-ClusterParameter -Name StartupParameters -value ' --config "C:\zabbix\ClusterGroup1\zabbix_agentd.conf"' 
				Start-ClusterResource -Name "ZABBIX Agent ($FAILOVERCLUSTERNETWORKNAME)"
				$SQLIPAddress = Get-ClusterResource -name "SQL IP Address*" | Select-Object -ExpandProperty Name
				Get-ClusterResource -name "ZABBIX Agent*" | Add-ClusterResourceDependency -Provider "$SQLIPAddress"
			}
			if (Get-ClusterResource -Name "ZABBIX Agent ($FAILOVERCLUSTERNETWORKNAME)") {
				Write-Host -Object ''
				write-host "Cluster Zabbix Agent is Configured Successfully!! Please review Status on Active node and add proper templates in zabbix console. "     -ForegroundColor green
				Write-Host -Object ''
				Write-Host -Object ''
				pause
				sqlPostInstallation
			}
			else {
				Write-Host -Object ''
				write-host "Cluster ZABBIX Agent failed to add as cluster Resources. Please review and validate the service status manaully."     -ForegroundColor red
				Write-Host -Object ''
				Write-Host -Object ''
				pause
				sqlPostInstallation
			}                   
		}
		else {
			Write-Host -Object ''
			write-host "Zabbix files are not copied!!! Please validate the Destination path(C:\Zabbix) and LocalZabbixCopy.log"     -ForegroundColor yellow
			pause
			sqlPostInstallation
		}
	}
}

Function UpdateMnemonic {
	if (Get-Module -ListAvailable -Name sqlserver) {
		Import-Module sqlserver
	} 
	else {
		[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
		find-module sqlserver | Install-Module -AllowClobber -Confirm:$False -Force
		Import-Module sqlserver
	}
	$UPDATEQuery = @"
UPDATE CWxDatabaseMaintenance set config_value='$Mnemonic' where config_type='Monitoring' and config_name='CEM_Mnemonic'
"@
	Invoke-Sqlcmd -ServerInstance $FAILOVERCLUSTERNETWORKNAME -Database cssumitMon -Query $UPDATEQuery
}


Function sqlMonitoring {
	$global:FAILOVERCLUSTERNETWORKNAME = Get-ClusterResource -Name "SQL Server" | Get-ClusterParameter -Name "VirtualServerName" | select -ExpandProperty Value
	Write-Host -Object ''
	Write-Host -Object ''
	Write-Host -Object 'Configuring Microsoft SQL Server monitoring:'   -ForegroundColor green
	Write-Host -Object ''
	if (Get-Module -ListAvailable -Name sqlserver) {
		Import-Module sqlserver
	} 
	else {
		[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
		find-module sqlserver | Install-Module -AllowClobber -Confirm:$False -Force
		Import-Module sqlserver
	}
	$global:Environment = Read-Host -Prompt 'Please enter DB Environment(1=Prod,2=NonProd)'
	Write-Host -Object ''
	$global:Mnemonic = Read-Host -Prompt 'Please enter the Client Mnemonic'
	$DBSERVER = [System.Net.Dns]::GetHostName()
	if ((Get-WmiObject Win32_ComputerSystem).Domain -eq "domain.com") {
		if (($Environment -eq "PROD") -or ($Environment -eq "1")) {
			try {
				Write-Host -Object ''
				Write-Host -Object 'Running SQL Monitoring Script, Please allow some time...'   -ForegroundColor green
				Write-Host -Object ''
				Invoke-Sqlcmd  -ServerInstance $FAILOVERCLUSTERNETWORKNAME `
					-Database master `
					-InputFile \\cssumitwhq4\CSMDBA\DB\SQLInstall\sqlScript_prod.sql `
					-QueryTimeout 120 `
					-ErrorAction Stop `
					-ErrorVariable sqlerror `
					-OutputSqlErrors $true `
					-DisableVariables `
					-verbose | format-table -AutoSize
				Write-Host -Object ''
				Write-Host -Object 'We have few Expected NBU errors, please work with NBU team to configure policies and retry backups jobs.'   -ForegroundColor yellow
				Write-Host -Object ''
				Write-Host -Object 'Below are the key parameters from CWxDatabaseMaintenance table, please review and update it manually if any changes required.'   -ForegroundColor green
				Write-Host -Object ''
				UpdateMnemonic                     #Calling Function
				Invoke-Sqlcmd -ServerInstance $FAILOVERCLUSTERNETWORKNAME -Database cssumitMon -Query "SELECT [config_name],[config_value] FROM [cssumitMon].[dbo].[CWxDatabaseMaintenance] where config_name in('script_version','Region','browse_client','policy_server','Prod_NonProd','CEM_Enable','CEM_Mnemonic','CEM_Server','OperatorEmail','on_call_operator')" | format-table -AutoSize
			}					
			catch {
				Write-Host -Object ''
				Write-Host "File:" $f.FullName 
				Write-Error $_.Exception.Message
				Write-Host -ForegroundColor red $Error[0].Exception
			}
			finally {
				Write-Host -Object ''
				Get-Date
				Write-Host -Object 'SQL Monitoring Script is Completed, Please see the console output for more information.'   -ForegroundColor green
				pause
				sqlPostInstallation
			}
		}
		elseif (($Environment -eq "NONPROD") -or ($Environment -eq "2")) {
			try {
				Write-Host -Object ''
				Write-Host -Object 'Running SQL Monitoring Script, Please allow some time...'   -ForegroundColor green
				Write-Host -Object ''
				Invoke-Sqlcmd  -ServerInstance $FAILOVERCLUSTERNETWORKNAME `
					-Database master `
					-InputFile \\cssumitwhq4\CSMDBA\DB\SQLInstall\sqlScript_nonprod.sql `
					-QueryTimeout 120 `
					-ErrorAction Stop `
					-ErrorVariable sqlerror `
					-OutputSqlErrors $true `
					-DisableVariables `
					-verbose | format-table -AutoSize
				Write-Host -Object ''
				Write-Host -Object 'We have few Expected NBU errors, please work with NBU team to configure policies and retry backups jobs.'   -ForegroundColor yellow
				Write-Host -Object ''
				Write-Host -Object 'Below are the key parameters from CWxDatabaseMaintenance table, please review and update it manually if any changes required.'   -ForegroundColor green
				Write-Host -Object ''
				UpdateMnemonic                      #Calling Function
				Invoke-Sqlcmd -ServerInstance $FAILOVERCLUSTERNETWORKNAME -Database cssumitMon -Query "SELECT [config_name],[config_value] FROM [cssumitMon].[dbo].[CWxDatabaseMaintenance] where config_name in('script_version','Region','browse_client','policy_server','Prod_NonProd','CEM_Enable','CEM_Mnemonic','CEM_Server','OperatorEmail','on_call_operator')" | format-table -AutoSize
			}
			catch {
				Write-Host -Object ''
				Write-Host "File:" $f.FullName 
				Write-Error $_.Exception.Message
				Write-Host -ForegroundColor red $Error[0].Exception
			}
			finally {
				Write-Host -Object ''
				Get-Date
				Write-Host -Object 'SQL Monitoring Script is Completed, Please see the console output for more information.'   -ForegroundColor green
				pause
				sqlPostInstallation
			}
		}
		else {
			Write-Host -Object 'Please Provide a Valid Environment, expected values (1=Prod,2=NonProd)'   -ForegroundColor red
			Write-Host -Object ''
			pause
			sqlMonitoring
		}
	}		
	elseif ((Get-WmiObject Win32_ComputerSystem).Domain -eq "domain_2.com") {
		if (($Environment -eq "PROD") -or ($Environment -eq "1")) {
			try {
				Write-Host -Object ''
				Write-Host -Object 'Running SQL Monitoring Script, Please allow some time...'   -ForegroundColor green
				Write-Host -Object ''
				Invoke-Sqlcmd  -ServerInstance $FAILOVERCLUSTERNETWORKNAME `
					-Database master `
					-InputFile \\cs-softwarelocation\ASPSQL_CSM\SQLInstall\sqlScript_prod.sql `
				-QueryTimeout 120 `
					-ErrorAction Stop `
					-ErrorVariable sqlerror `
					-OutputSqlErrors $true `
					-DisableVariables `
					-verbose | format-table -AutoSize
				Write-Host -Object ''
				Write-Host -Object 'We have few Expected NBU errors, please work with NBU team to configure policies and retry backups jobs.'   -ForegroundColor yellow
				Write-Host -Object ''
				Write-Host -Object 'Below are the key parameters from CWxDatabaseMaintenance table, please review and update it manually if any changes required.'   -ForegroundColor green
				Write-Host -Object ''
				UpdateMnemonic                       #Calling Function
				Invoke-Sqlcmd -ServerInstance $FAILOVERCLUSTERNETWORKNAME -Database cssumitMon -Query "SELECT [config_name],[config_value] FROM [cssumitMon].[dbo].[CWxDatabaseMaintenance] where config_name in('script_version','Region','browse_client','policy_server','Prod_NonProd','CEM_Enable','CEM_Mnemonic','CEM_Server','OperatorEmail','on_call_operator')" | format-table -AutoSize
			}
			catch {
				Write-Host -Object ''
				Write-Host "File:" $f.FullName 
				Write-Error $_.Exception.Message
				Write-Host -ForegroundColor red $Error[0].Exception
			}
			finally {
				Write-Host -Object ''
				Get-Date
				Write-Host -Object 'SQL Monitoring Script is Completed, Please see the console output for more information.'   -ForegroundColor green
				pause
				sqlPostInstallation
			}
		}
		elseif (($Environment -eq "NONPROD") -or ($Environment -eq "2")) {
			try {
				Write-Host -Object ''
				Write-Host -Object 'Running SQL Monitoring Script, Please allow some time...'   -ForegroundColor green
				Write-Host -Object ''
				Invoke-Sqlcmd  -ServerInstance $FAILOVERCLUSTERNETWORKNAME `
					-Database master `
					-InputFile \\cs-softwarelocation\ASPSQL_CSM\SQLInstall\sqlScript_nonprod.sql `
					-QueryTimeout 120 `
					-ErrorAction Stop `
					-ErrorVariable sqlerror `
					-OutputSqlErrors $true `
					-DisableVariables `
					-verbose | format-table -AutoSize
				Write-Host -Object ''
				Write-Host -Object 'We have few Expected NBU errors, please work with NBU team to configure policies and retry backups jobs.'   -ForegroundColor yellow
				Write-Host -Object ''
				Write-Host -Object 'Below are the key parameters from CWxDatabaseMaintenance table, please review and update it manually if any changes required.'   -ForegroundColor green
				Write-Host -Object ''
				UpdateMnemonic                       #Calling Function
				Invoke-Sqlcmd -ServerInstance $FAILOVERCLUSTERNETWORKNAME -Database cssumitMon -Query "SELECT [config_name],[config_value] FROM [cssumitMon].[dbo].[CWxDatabaseMaintenance] where config_name in('script_version','Region','browse_client','policy_server','Prod_NonProd','CEM_Enable','CEM_Mnemonic','CEM_Server','OperatorEmail','on_call_operator')" | format-table -AutoSize
			}
			catch {
				Write-Host -Object ''
				Write-Host "File:" $f.FullName 
				Write-Error $_.Exception.Message
				Write-Host -ForegroundColor red $Error[0].Exception
			}
			finally {
				Write-Host -Object ''
				Get-Date
				Write-Host -Object 'SQL Monitoring Script is Completed, Please see the console output for more information.'   -ForegroundColor green
				pause
				sqlPostInstallation
			}
		}
		else {
			Write-Host -Object 'Please Provide a Valid Environment, expected values (1=Prod,2=NonProd)'   -ForegroundColor red
			Write-Host -Object ''
			pause
			sqlMonitoring
		}
	}
}

Function sqlbackupsPolicies {
	if (Get-Module -ListAvailable -Name sqlserver) {
		Import-Module sqlserver
	} 
	else {
		[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
		find-module sqlserver | Install-Module -AllowClobber -Confirm:$False -Force
		Import-Module sqlserver
	}
	if ((Get-WmiObject Win32_ComputerSystem).Domain -eq "domain.com") {
		try {
			Write-Host -Object ''
			Write-Host -Object 'Extracting the backup policies...'   -ForegroundColor green
			Start-Sleep -Seconds 5
			Write-Host -Object ''
			Write-Host -Object 'Below are the backups policies detail...'   -ForegroundColor yellow
			Write-Host -Object ''
			Invoke-Sqlcmd  -ServerInstance $FAILOVERCLUSTERNETWORKNAME `
				-Database master `
				-InputFile \\cssumitwhq4\CSMDBA\DB\SQLInstall\CWxDatabaseMaintenance_PreSetup_Simplified.sql `
				-QueryTimeout 120 `
				-ErrorAction Stop `
				-ErrorVariable sqlerror `
				-OutputSqlErrors $true `
				-DisableVariables `
				-verbose
		}
		catch {
			Write-Host -Object ''
			Write-Host "File:" $f.FullName 
			Write-Error $_.Exception.Message
			Write-Host -ForegroundColor red $Error[0].Exception
		}
		finally {
			Write-Host -Object ''
			Write-Host -Object 'Please make a note of backups Policies and log ticket for backups configuration. Once backup policies are configured, retry the backups jobs.'   -ForegroundColor green
			Write-Host -Object ''
			pause
			sqlPostInstallation
		}
	}
	elseif ((Get-WmiObject Win32_ComputerSystem).Domain -eq "domain_2.com") {
		try {
			Write-Host -Object ''
			Write-Host -Object 'Extracting the backup policies...'   -ForegroundColor green
			Start-Sleep -Seconds 5
			Write-Host -Object ''
			Write-Host -Object 'Below are the backups policies detail...'   -ForegroundColor yellow
			Write-Host -Object ''
			Invoke-Sqlcmd  -ServerInstance $FAILOVERCLUSTERNETWORKNAME `
				-Database master `
				-InputFile \\cs-softwarelocation\ASPSQL_CSM\SQLInstall\CWxDatabaseMaintenance_PreSetup_Simplified.sql `
				-QueryTimeout 120 `
				-ErrorAction Stop `
				-ErrorVariable sqlerror `
				-OutputSqlErrors $true `
				-DisableVariables `
				-verbose 
		}
		catch {
			Write-Host -Object ''
			Write-Host "File:" $f.FullName 
			Write-Error $_.Exception.Message
			Write-Host -ForegroundColor red $Error[0].Exception
		}
		finally {
			Write-Host -Object ''
			Write-Host -Object 'Please make a note of SQL backups Policies and log ask ticket for backups configuration and work with NBU team before retry backups jobs.'   -ForegroundColor green
			pause
			sqlPostInstallation
		}
	}
}
							

Function sqlInstallationTask {
	Clear-Host        
	Do {
		Clear-Host
		Write-Host ("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++") -ForegroundColor cyan
		Write-Host ("+                SQL.Next ==> SQL Server Automation                +")  -ForegroundColor cyan
		Write-Host ("+                    Written By: SUMIT KUMAR                       +") -ForegroundColor cyan
		Write-Host ("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++") -ForegroundColor cyan
		Write-Host ("!!             	                                                  !!") -ForegroundColor cyan
		Write-Host ("!!             	                                                  !!") -ForegroundColor cyan
		Write-Host ("--------------------------------------------------------------------") -ForegroundColor cyan
		Write-Host ("!!               SQL server Failover Cluster Installation         !!") -ForegroundColor cyan
		Write-Host ("--------------------------------------------------------------------")    -ForegroundColor cyan
		Write-Host ("!!             	                                                  !!") -ForegroundColor cyan
		Write-Host ******************************************************************** -ForegroundColor cyan
		Write-Host ("                                                                    ")  -ForegroundColor cyan
		Write-Host ******************************************************************** -ForegroundColor cyan
		Write-Host -Object '' 
		Write-Host -Object '' 
		Write-Host -Object '1. New SQL Server failover cluster installation:  '
		Write-Host -Object ''
		Write-Host -Object '2. Add node to a SQL Server failover cluster: '
		Write-Host -Object ''
		Write-Host -Object '3. Main Menu: '
		Write-Host -Object $errout
		$sqlInstallationTask = Read-Host -Prompt 'Select Options to Proceed'
		Get-Disk | Where-Object { $_.TotalSize -eq 10 }
		switch ($sqlInstallationTask) {
			1 {
				Write-Host -Object ''
				Write-Host "Installation of SQL Server Failover Cluster Instance (FCI)..." -foregroundcolor "green"
				Write-Host -Object ''
				#Get No Of CPU On the server
				$colItems = Get-WmiObject -class "Win32_Processor" -namespace "root/CIMV2" 
				$NOfLogicalCPU = 0
				foreach ($objcpu in $colItems)
				{ $NOfLogicalCPU = $NOfLogicalCPU + $objcpu.NumberOfLogicalProcessors }
				  
				$DBSERVER = [System.Net.Dns]::GetHostName()

				#Get Rem on the server
				$mem = Get-WmiObject -Class Win32_ComputerSystem  
				$HostPhysicalMemoryGB = $($mem.TotalPhysicalMemory / 1Mb) 
				$HostPhysicalMemoryGB = [math]::floor($HostPhysicalMemoryGB)
			
				#List out the Initial Parameters for Users Confirmation
				$installationAccount = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
				write-host "`nServer Name is: "     -ForegroundColor yellow -NoNewline
				write-host "$DBSERVER"     -ForegroundColor green
				write-host "`nTotal CPU: " -ForegroundColor yellow -NoNewline
				write-host "$NOfLogicalCPU"      -ForegroundColor green
				write-host "`nTotal Memory: "     -ForegroundColor yellow -NoNewline
				write-host "$HostPhysicalMemoryGB"     -ForegroundColor green
				$ClusterName = Get-Cluster | Select-Object -ExpandProperty Name
				write-host "`nWindows Server Failover Cluster Name: = "     -ForegroundColor yellow -NoNewline
				write-host "$ClusterName" -ForegroundColor green 
				$ClusterIP = Get-ClusterGroup | Where-Object { $_.GroupType -eq "Cluster" } | Get-ClusterResource | Where-Object { $_.ResourceType -eq "IP Address" } |  Get-ClusterParameter -Name "Address" | Select-Object -ExpandProperty "Value"
				write-host "`nWindows Server Failover Clustering (WSFC) IP = "     -ForegroundColor yellow -NoNewline
				write-host "$ClusterIP" -ForegroundColor green
				write-host "`nAccount running the SQL Server Installation Script: =  "     -ForegroundColor yellow -NoNewline
				write-host "$installationAccount"     -ForegroundColor green
				Write-Host -Object ''
				Write-Host -Object ''
				#region commonCode
				# Execute this to ensure Powershell has execution rights
				#Set-ExecutionPolicy Unrestricted -Force
				#Set-ExecutionPolicy bypass
				#Import-Module ServerManager 
				#Add-WindowsFeature PowerShell-ISE
				sqlVersion                                    ## Calling Function
				Write-Host -Object ''
				CopyMedia                                   ## Calling Function
				Write-Host -Object ''
				#$INSTANCEDIR="C:\Program Files\Microsoft SQL Server"
				$INSTANCEID = "MSSQLSERVER"
				$INSTANCENAME = "MSSQLSERVER"
				$FAILOVERCLUSTERGROUP = "SQL Server (MSSQLSERVER)"
				$global:FAILOVERCLUSTERNETWORKNAME = Read-Host -Prompt 'Enter the SQL Server Cluster Name(Instance Name)'
				Write-Host -Object ''
				$SQLIP = Read-Host -Prompt 'Enter the SQL Server Instance IP '
				Write-Host -Object ''
				#write-host "Cluster Network Name - " -ForegroundColor green -NoNewline
				#write-host "You can retrieve this information in the Networks section of the Failover Cluster Manager and identifying the cluster network configured with Cluster and Client. It should be in the same network range as Nodes, FCI and SQL VIP." -ForegroundColor yellow
				#Write-Host -Object ''
				$NIC = Get-ClusterResource | Where { $_.ResourceType -eq "IP Address" -and $_.OwnerGroup -eq "Cluster Group" } | Get-ClusterParameter -Name "Network" | Select-Object -ExpandProperty "Value"
				$SubnetMask = Get-ClusterResource | Where { $_.ResourceType -eq "IP Address" -and $_.OwnerGroup -eq "Cluster Group" } | Get-ClusterParameter -Name "SubnetMask" | Select-Object -ExpandProperty "Value"
				$FAILOVERCLUSTERIPADDRESSES = "IPv4;$SQLIP;$NIC;$SubnetMask"
				$FAILOVERCLUSTERDISKS = Get-Volume | Where-Object -FilterScript { $_.DriveLetter -eq "Z" } | Select-Object -ExpandProperty "FileSystemLabel"
				Write-Host "Configure SQL Server Service Accounts:"    -ForegroundColor green
				sqlAccounts                                     ## Calling Function
				#$SQLSVCPASSWORD=Read-Host -Prompt 'Enter the Service Account Password ("In Double Quotes")'
				Write-Host -Object ''
				$AGTSVCACCOUNT = $SQLSVCACCOUNT
				$AGTSVCPASSWORD = $SQLSVCPASSWORD
				AdminAccountSQL                                     ## Calling Function
				#Write-Host -Object ''
				$SAPWD = "sa4SQL!c"
				$UpdateSource = 'C:\Downloads\SQLUpdates'
				$SQLBackupDIR = "Z:\Backups\Disk1\sql_bak"
				#write-host "Backups Files Location is ("$SQLBackupDIR")"     -ForegroundColor green
				#Write-Host -Object ''
				$collation = "SQL_Latin1_General_CP1_CI_AS"
				#Temp FIles Creation Based on CPU count.
				if ($NOfLogicalCPU -gt 8) { $SQLTEMPDBFILECOUNT = 8 } else { $SQLTEMPDBFILECOUNT = $NOfLogicalCPU }
				$SQLTempDBDIR = "Z:\TempDB\Disk1\sql_dat"
				#write-host "`TEMPDB Data Files Location("$SQLTempDBDIR")"     -ForegroundColor green
				#Write-Host -Object ''
				$SQLTEMPDBLOGDIR = "Z:\Log\Disk1\sql_log"
				#write-host "`TEMPDB Log Files Location("$SQLTEMPDBLOGDIR")"     -ForegroundColor green
				#Write-Host -Object ''
				$SQLUSERDBDIR = "Z:\Data\Disk1\sql_dat"
				#write-host "`USERs Data Files Location("$SQLUSERDBDIR")"     -ForegroundColor green
				#Write-Host -Object ''
				$SQLUSERDBLOGDIR = "Z:\Log\Disk1\sql_log"
				#write-host "`USERs Data Files Location("$SQLUSERDBLOGDIR")"     -ForegroundColor green
				#Write-Host -Object ''
				$INSTALLSQLDATADIR = "Z:\System\Disk1"
				#write-host "`USERs Data Files Location("$INSTALLSQLDATADIR")"     -ForegroundColor green
				#Write-Host -Object ''
				$SQLFEATURES = 'SQLENGINE,REPLICATION,FULLTEXT,DQC,CONN,BC,SDK,SNAC_SDK,MDS'
				#Write-Host -Object 'SQL Engine ...  '  -ForegroundColor Green
				#$SQLFEATURES=Read-Host -Prompt 'Specifies features to install, Supported values are SQLEngine, Replication, FullText, DQ, AS, AS_SPI, RS, RS_SHP, RS_SHPWFE, DQC, Conn, IS, BC, SDK, DREPLAY_CTLR, DREPLAY_CLT, SNAC_SDK, SQLODBC, SQLODBC_SDK, LocalDB, MDS, POLYBASE'
				write-host "`nSQL Instalation ready to proceed please confirm below details:"     -ForegroundColor green
				Write-Host -Object ''
				Write-Host -Object ''
				write-host "`Server Name: "     -ForegroundColor yellow -NoNewline
				write-host "$DBSERVER" -ForegroundColor green 
				Write-Host -Object ''
				write-host "Total CPU: "     -ForegroundColor yellow  -NoNewline
				write-host "$NOfLogicalCPU" -ForegroundColor green 
				Write-Host -Object ''
				write-host "Total Physical memory: "     -ForegroundColor yellow  -NoNewline
				write-host "$HostPhysicalMemoryGB MB" -ForegroundColor green 
				Write-Host -Object ''
				write-host "SQL Server Installation Media DIR = "     -ForegroundColor yellow  -NoNewline
				write-host "$SQLBinariesLocation" -ForegroundColor green 
				Write-Host -Object ''
				write-host "FEATURES: "     -ForegroundColor yellow  -NoNewline
				write-host "$SQLFEATURES" -ForegroundColor green 
				Write-Host -Object ''
				write-host "INSTANCE DIR = "     -ForegroundColor yellow  -NoNewline
				write-host "$INSTALLSQLDATADIR" -ForegroundColor green 
				Write-Host -Object ''
				write-host "Backups Files DIR = "     -ForegroundColor yellow  -NoNewline
				write-host "$SQLBACKUPDIR" -ForegroundColor green 
				Write-Host -Object ''
				write-host "USERs DATA Files DIR = "     -ForegroundColor yellow  -NoNewline
				write-host "$SQLUSERDBDIR" -ForegroundColor green 
				Write-Host -Object ''
				write-host "USERs LOG Files DIR = "     -ForegroundColor yellow  -NoNewline
				write-host "$SQLUSERDBLOGDIR" -ForegroundColor green 
				Write-Host -Object ''
				write-host "TEMPDB DATA Files DIR = "     -ForegroundColor yellow  -NoNewline
				write-host "$SQLTEMPDBDIR" -ForegroundColor green 
				Write-Host -Object ''
				write-host "Number of Temp Files to Create = "     -ForegroundColor yellow  -NoNewline
				write-host "$SQLTEMPDBFILECOUNT" -ForegroundColor green 
				Write-Host -Object ''
				write-host "SQL Server Cluster Name(Instance Name) = "     -ForegroundColor yellow  -NoNewline
				write-host "$FAILOVERCLUSTERNETWORKNAME" -ForegroundColor green
				Write-Host -Object ''
				write-host "SQL Server Instance IP = "     -ForegroundColor yellow  -NoNewline
				write-host "$SQLIP" -ForegroundColor green
				Write-Host -Object ''
				write-host "SQL Server Failover Cluster Instance = "     -ForegroundColor yellow  -NoNewline
				write-host "$FAILOVERCLUSTERGROUP" -ForegroundColor green
				Write-Host -Object ''
				write-host "Cluster Disk Name (Mount Disk) = "     -ForegroundColor yellow  -NoNewline
				write-host "$FAILOVERCLUSTERDISKS" -ForegroundColor green
				Write-Host -Object ''
				write-host "Encoded FAILOVER CLUSTER IP ADDRESSES = "     -ForegroundColor yellow  -NoNewline
				write-host "$FAILOVERCLUSTERIPADDRESSES" -ForegroundColor green 
				Write-Host -Object ''
				write-host "SQL Server system administrators= "  -ForegroundColor yellow  -NoNewline
				write-host "$SQLSYSADMINACCOUNTS" -ForegroundColor green 
				Write-Host -Object ''
				write-host "Service Account (Database Services/Agent)= "  -ForegroundColor yellow  -NoNewline
				write-host "$SQLSVCACCOUNT" -ForegroundColor green
				Write-Host -Object ''
				Write-Host -Object ''
				write-host "Press "  -ForegroundColor yellow -NoNewline
				write-host "[ENTER]"  -ForegroundColor green  -NoNewline
				write-host " to continue or "  -ForegroundColor yellow   -NoNewline
				write-host "CTRL+C"  -ForegroundColor red   -NoNewline
				write-host " to quit."  -ForegroundColor yellow
				Write-Host -Object ''

				pause

				$date = Get-Date -format "yyyy-MM-dd HH:mm:ss" 
				Write-Host -Object ''
				Write-Host "$date Starting SQL Server installation"    -ForegroundColor Green
				Write-Host -Object ''
				
				if ($version -eq "2019") {
					if ($InstanceName -eq "MSSQLSERVER") {
						Set-Location $SQLBinariesLocation
						.\setup.exe /QS /ACTION=InstallFailoverCluster /FEATURES=$SQLFEATURES /ENU /UpdateEnabled=1 /UpdateSource=$UpdateSource /ERRORREPORTING=0 /INSTANCEDIR="C:\Program Files\Microsoft SQL Server" /INSTANCENAME=MSSQLSERVER /SQMREPORTING=0 /INSTANCEID=MSSQLSERVER /SQLSVCACCOUNT=$SQLSVCACCOUNT /SQLSVCPASSWORD=$SQLSVCPASSWORD /AGTSVCACCOUNT=$AGTSVCACCOUNT /AGTSVCPASSWORD=$AGTSVCPASSWORD /SQLSYSADMINACCOUNTS=$SQLSYSADMINACCOUNTS /SkipRules=Cluster_VerifyForWarnings /FAILOVERCLUSTERIPADDRESSES="$FAILOVERCLUSTERIPADDRESSES" /FAILOVERCLUSTERDISKS="$FAILOVERCLUSTERDISKS" /FAILOVERCLUSTERNETWORKNAME=$FAILOVERCLUSTERNETWORKNAME /FAILOVERCLUSTERGROUP="SQL Server (MSSQLSERVER)" /SAPWD=$SAPWD /SECURITYMODE=SQL /INSTALLSQLDATADIR=$INSTALLSQLDATADIR /SQLBACKUPDIR=$SQLBackupDIR /SQLCOLLATION=$collation /SQLTEMPDBDIR=$SQLTEMPDBDIR /SQLTEMPDBLOGDIR=$SQLTempDBLogDIR /SQLUSERDBDIR=$SQLUserDBDIR /SQLUSERDBLOGDIR=$SQLUserDBLogDIR /SQLTEMPDBFILECOUNT=$SQLTEMPDBFILECOUNT /SQLSVCINSTANTFILEINIT="True" /USESQLRECOMMENDEDMEMORYLIMITS="True" /IACCEPTSQLSERVERLICENSETERMS
						
					}
					else {
						Set-Location $SQLBinariesLocation
						.\setup.exe /QS /ACTION=InstallFailoverCluster /FEATURES=$SQLFEATURES /ENU /UpdateEnabled=1 /UpdateSource=$UpdateSource /ERRORREPORTING=0 /INSTANCEDIR="C:\Program Files\Microsoft SQL Server" /INSTANCENAME=$InstanceName /SQMREPORTING=0 /INSTANCEID=$InstanceName /SQLSVCACCOUNT=$SQLSVCACCOUNT /SQLSVCPASSWORD=$SQLSVCPASSWORD /AGTSVCACCOUNT=$AGTSVCACCOUNT /AGTSVCPASSWORD=$AGTSVCPASSWORD /SQLSYSADMINACCOUNTS=$SQLSYSADMINACCOUNTS /SkipRules=Cluster_VerifyForWarnings /FAILOVERCLUSTERIPADDRESSES="$FAILOVERCLUSTERIPADDRESSES" /FAILOVERCLUSTERDISKS="$FAILOVERCLUSTERDISKS" /FAILOVERCLUSTERNETWORKNAME=$FAILOVERCLUSTERNETWORKNAME /FAILOVERCLUSTERGROUP="SQL Server (MSSQLSERVER)" /SAPWD=$SAPWD /SECURITYMODE=SQL /INSTALLSQLDATADIR=$INSTALLSQLDATADIR /SQLBACKUPDIR=$SQLBackupDIR /SQLCOLLATION=$collation /SQLTEMPDBDIR=$SQLTEMPDBDIR /SQLTEMPDBLOGDIR=$SQLTempDBLogDIR /SQLUSERDBDIR=$SQLUserDBDIR /SQLUSERDBLOGDIR=$SQLUserDBLogDIR /SQLTEMPDBFILECOUNT=$SQLTEMPDBFILECOUNT /SQLSVCINSTANTFILEINIT="True" /USESQLRECOMMENDEDMEMORYLIMITS="True" /IACCEPTSQLSERVERLICENSETERMS  
						
					}
				}
				
				if ($version -eq "2017") {
					if ($InstanceName -eq "MSSQLSERVER") {
						Set-Location $SQLBinariesLocation
						.\setup.exe /QS /ACTION=InstallFailoverCluster /FEATURES=$SQLFEATURES /ENU /UpdateEnabled=1 /UpdateSource=$UpdateSource /ERRORREPORTING=0 /INSTANCEDIR="C:\Program Files\Microsoft SQL Server" /INSTANCENAME=MSSQLSERVER /SQMREPORTING=0 /SQLSVCACCOUNT=$SQLSVCACCOUNT /SQLSVCPASSWORD=$SQLSVCPASSWORD /AGTSVCACCOUNT=$AGTSVCACCOUNT /AGTSVCPASSWORD=$AGTSVCPASSWORD /SQLSYSADMINACCOUNTS=$SQLSYSADMINACCOUNTS /SkipRules=Cluster_VerifyForWarnings /FAILOVERCLUSTERIPADDRESSES="$FAILOVERCLUSTERIPADDRESSES" /FAILOVERCLUSTERDISKS="$FAILOVERCLUSTERDISKS" /FAILOVERCLUSTERNETWORKNAME=$FAILOVERCLUSTERNETWORKNAME /FAILOVERCLUSTERGROUP="SQL Server (MSSQLSERVER)" /SAPWD=$SAPWD /SECURITYMODE=SQL /INSTALLSQLDATADIR=$INSTALLSQLDATADIR /SQLBACKUPDIR=$SQLBackupDIR /SQLCOLLATION=$collation /SQLTEMPDBDIR=$SQLTEMPDBDIR /SQLTEMPDBLOGDIR=$SQLTempDBLogDIR /SQLUSERDBDIR=$SQLUserDBDIR /SQLUSERDBLOGDIR=$SQLUserDBLogDIR /SQLTEMPDBFILECOUNT=$SQLTEMPDBFILECOUNT /SQLSVCINSTANTFILEINIT="True" /IACCEPTSQLSERVERLICENSETERMS
						
					}
					else {
						Set-Location $SQLBinariesLocation
						.\setup.exe /QS /ACTION=Install /FEATURES=$SQLFEATURES /ENU /UpdateEnabled=1 /UpdateSource=$UpdateSource /ERRORREPORTING=0 /INSTANCEDIR="C:\Program Files\Microsoft SQL Server" /INSTANCEID=$InstanceName /INSTANCENAME=$InstanceName /SQMREPORTING=0 /SQLSVCACCOUNT=$SQLSVCACCOUNT /SQLSVCPASSWORD=$SQLSVCPASSWORD /AGTSVCACCOUNT=$AGTSVCACCOUNT /AGTSVCPASSWORD=$AGTSVCPASSWORD /SQLSYSADMINACCOUNTS=$SQLSYSADMINACCOUNTS /SAPWD=$SAPWD /SECURITYMODE=SQL /AGTSVCSTARTUPTYPE="Automatic" /BROWSERSVCSTARTUPTYPE="Disabled" /INSTALLSQLDATADIR=$INSTALLSQLDATADIR /SQLBACKUPDIR=$SQLBackupDIR /SQLCOLLATION=$collation /SQLSVCSTARTUPTYPE="Automatic" /SQLTEMPDBDIR=$SQLTEMPDBDIR /SQLTEMPDBLOGDIR=$SQLTempDBLogDIR /SQLUSERDBDIR=$SQLUserDBDIR /SQLUSERDBLOGDIR=$SQLUserDBLogDIR /SQLTEMPDBFILECOUNT=4 /IACCEPTSQLSERVERLICENSETERMS  
						
					}
				}

				if ($version -eq "2016") {
					if ($InstanceName -eq "MSSQLSERVER") {
						Set-Location $SQLBinariesLocation
						.\setup.exe /QS /ACTION=InstallFailoverCluster /FEATURES=$SQLFEATURES /ENU /UpdateEnabled=1 /UpdateSource=$UpdateSource /ERRORREPORTING=0 /INSTANCEDIR="C:\Program Files\Microsoft SQL Server" /INSTANCENAME=MSSQLSERVER /SQMREPORTING=0 /SQLSVCACCOUNT=$SQLSVCACCOUNT /SQLSVCPASSWORD=$SQLSVCPASSWORD /AGTSVCACCOUNT=$AGTSVCACCOUNT /AGTSVCPASSWORD=$AGTSVCPASSWORD /SQLSYSADMINACCOUNTS=$SQLSYSADMINACCOUNTS /SkipRules=Cluster_VerifyForWarnings /FAILOVERCLUSTERIPADDRESSES="$FAILOVERCLUSTERIPADDRESSES" /FAILOVERCLUSTERDISKS="$FAILOVERCLUSTERDISKS" /FAILOVERCLUSTERNETWORKNAME=$FAILOVERCLUSTERNETWORKNAME /FAILOVERCLUSTERGROUP="SQL Server (MSSQLSERVER)" /SAPWD=$SAPWD /SECURITYMODE=SQL /INSTALLSQLDATADIR=$INSTALLSQLDATADIR /SQLBACKUPDIR=$SQLBackupDIR /SQLCOLLATION=$collation /SQLTEMPDBDIR=$SQLTEMPDBDIR /SQLTEMPDBLOGDIR=$SQLTempDBLogDIR /SQLUSERDBDIR=$SQLUserDBDIR /SQLUSERDBLOGDIR=$SQLUserDBLogDIR /SQLTEMPDBFILECOUNT=$SQLTEMPDBFILECOUNT /SQLSVCINSTANTFILEINIT="True" /IACCEPTSQLSERVERLICENSETERMS
						
					}
					else {
						Set-Location $SQLBinariesLocation
						.\setup.exe /QS /ACTION=Install /FEATURES=$SQLFEATURES /ENU /UpdateEnabled=1 /UpdateSource=$UpdateSource /ERRORREPORTING=0 /INSTANCEDIR="C:\Program Files\Microsoft SQL Server" /INSTANCEID=$InstanceName /INSTANCENAME=$InstanceName /SQMREPORTING=0 /SQLSVCACCOUNT=$SQLSVCACCOUNT /SQLSVCPASSWORD=$SQLSVCPASSWORD /AGTSVCACCOUNT=$AGTSVCACCOUNT /AGTSVCPASSWORD=$AGTSVCPASSWORD /SQLSYSADMINACCOUNTS=$SQLSYSADMINACCOUNTS /SAPWD=$SAPWD /SECURITYMODE=SQL /AGTSVCSTARTUPTYPE="Automatic" /BROWSERSVCSTARTUPTYPE="Disabled" /INSTALLSQLDATADIR=$INSTALLSQLDATADIR /SQLBACKUPDIR=$SQLBackupDIR /SQLCOLLATION=$collation /SQLSVCSTARTUPTYPE="Automatic" /SQLTEMPDBDIR=$SQLTEMPDBDIR /SQLTEMPDBLOGDIR=$SQLTempDBLogDIR /SQLUSERDBDIR=$SQLUserDBDIR /SQLUSERDBLOGDIR=$SQLUserDBLogDIR /SQLTEMPDBFILECOUNT=4 /IACCEPTSQLSERVERLICENSETERMS
						
					}
				}

				elseif ($version -eq "2014") {
					if ($InstanceName -eq "MSSQLSERVER") {
						$SQLFEATURES = 'SQLENGINE,REPLICATION,FULLTEXT,DQ,DQC,CONN,BC,SDK,BOL'
						Set-Location $SQLBinariesLocation
						.\setup.exe /QS /ACTION=InstallFailoverCluster /FEATURES=$SQLFEATURES /ENU /UpdateEnabled=1 /UpdateSource=$UpdateSource /ERRORREPORTING=0 /INSTANCEDIR="C:\Program Files\Microsoft SQL Server" /INSTANCENAME=MSSQLSERVER /SQMREPORTING=0 /SQLSVCACCOUNT=$SQLSVCACCOUNT /SQLSVCPASSWORD=$SQLSVCPASSWORD /AGTSVCACCOUNT=$AGTSVCACCOUNT /AGTSVCPASSWORD=$AGTSVCPASSWORD /SQLSYSADMINACCOUNTS=$SQLSYSADMINACCOUNTS /SkipRules=Cluster_VerifyForWarnings /FAILOVERCLUSTERIPADDRESSES="$FAILOVERCLUSTERIPADDRESSES" /FAILOVERCLUSTERDISKS="$FAILOVERCLUSTERDISKS" /FAILOVERCLUSTERNETWORKNAME=$FAILOVERCLUSTERNETWORKNAME /FAILOVERCLUSTERGROUP="SQL Server (MSSQLSERVER)" /SAPWD=$SAPWD /SECURITYMODE=SQL /INSTALLSQLDATADIR=$INSTALLSQLDATADIR /SQLBACKUPDIR=$SQLBackupDIR /SQLCOLLATION=$collation /SQLTEMPDBDIR=$SQLTEMPDBDIR /SQLTEMPDBLOGDIR=$SQLTempDBLogDIR /SQLUSERDBDIR=$SQLUserDBDIR /SQLUSERDBLOGDIR=$SQLUserDBLogDIR /IACCEPTSQLSERVERLICENSETERMS
						
					}
					else {
						Set-Location $SQLBinariesLocation
						.\setup.exe /QS /ACTION=InstallFailoverCluster /FEATURES=$SQLFEATURES /ENU /UpdateEnabled=1 /UpdateSource=$UpdateSource /ERRORREPORTING=0 /INSTANCEDIR="C:\Program Files\Microsoft SQL Server" /INSTANCENAME=$InstanceName /SQMREPORTING=0 /SQLSVCACCOUNT=$SQLSVCACCOUNT /SQLSVCPASSWORD=$SQLSVCPASSWORD /AGTSVCACCOUNT=$AGTSVCACCOUNT /AGTSVCPASSWORD=$AGTSVCPASSWORD /SQLSYSADMINACCOUNTS=$SQLSYSADMINACCOUNTS /SkipRules=Cluster_VerifyForWarnings /FAILOVERCLUSTERIPADDRESSES="$FAILOVERCLUSTERIPADDRESSES" /FAILOVERCLUSTERDISKS="$FAILOVERCLUSTERDISKS" /FAILOVERCLUSTERNETWORKNAME=$FAILOVERCLUSTERNETWORKNAME /FAILOVERCLUSTERGROUP="SQL Server (MSSQLSERVER)" /SAPWD=$SAPWD /SECURITYMODE=SQL /INSTALLSQLDATADIR=$INSTALLSQLDATADIR /SQLBACKUPDIR=$SQLBackupDIR /SQLCOLLATION=$collation /SQLTEMPDBDIR=$SQLTEMPDBDIR /SQLTEMPDBLOGDIR=$SQLTempDBLogDIR /SQLUSERDBDIR=$SQLUserDBDIR /SQLUSERDBLOGDIR=$SQLUserDBLogDIR /IACCEPTSQLSERVERLICENSETERMS
						
					}
				}

				if ($InstanceName -eq "MSSQLSERVER") {
					$service = Get-WmiObject -Class Win32_Service -Filter "Name='MSSQLSERVER'"
				}
				else {
					$service = Get-WmiObject -Class Win32_Service -Filter "Name='$InstanceName'"
				}
				if (!($service.Name)) {
					Write-Host -Object ''
					Write-Host "SQL Service not found" -foregroundcolor "red"
					# Get setup failure message from summary.txt file
					switch ($version) { 
						"2019" { [string]$SQLVerNo = "150" } 
						"2017" { [string]$SQLVerNo = "140" } 
						"2016" { [string]$SQLVerNo = "130" } 
						"2014" { [string]$SQLVerNo = "120" } 
						"2012" { [string]$SQLVerNo = "110" } 
					}

					Write-Host -Object ''
					$SQLInstallationSummary = "$env:programfiles\Microsoft SQL Server\$SQLVerNo\Setup Bootstrap\Log\Summary.txt"

					if (!(test-path $SQLInstallationSummary)) { write-host -ForegroundColor Red "`nSummary file does not exists, setup failed for some basic reason, pleaes check this file location $SQLInstallationSummary"; exit }


					$SQLSetupErrorMessage = gc $SQLInstallationSummary | ? { ($_ | Select-String "Exit message:") }  
					if ($SQLSetupErrorMessage) { write-host ($SQLSetupErrorMessage.Replace("Exit message:", "") + "`n `n" + "For detiled error message check `n$SQLInstallationSummary`n") -foregroundcolor "red"; exit }
					else { write-host "Could not find SQL setup summary log file" -foregroundcolor "red" }
				}
				else {
					Write-Host "`nSQL Service found, Installation completed Successfully!!!" -foregroundcolor "green"
					# Get setup failure message from summary.txt file
					switch ($version) { 
						"2019" { [string]$SQLVerNo = "150" } 
						"2017" { [string]$SQLVerNo = "140" } 
						"2016" { [string]$SQLVerNo = "130" } 
						"2014" { [string]$SQLVerNo = "120" } 
						"2012" { [string]$SQLVerNo = "110" } 
					}
			
					Write-Host -Object ''
					$SQLInstallationSummary = "$env:programfiles\Microsoft SQL Server\$SQLVerNo\Setup Bootstrap\Log\Summary.txt"
			
					if (!(test-path $SQLInstallationSummary)) {
						write-host -ForegroundColor Red "`nSummary file does not exists, pleaes check the default Installation Log Summary File Location - " -nonewline
						write-host -ForegroundColor yellow "`C:\Program Files\Microsoft SQL Server\<SQLVerNo>\Setup Bootstrap\LOG\Summary.txt"
					}
					else {
						write-host -ForegroundColor yellow "`nPlease review $SQLInstallationSummary file for installation status of SQL Server components."
						Write-Host -Object ''
						notepad.exe $SQLInstallationSummary
					}
				}
			}
			2 {
				AddClusterNode
			} 
			3 {
				Menu
			} 
			default {
				$errout = 'Invalid option please try again........'
			}
		}
	}
	until ($sqlInstallationTask -ne '')
}


Function AddClusterNode {
	Write-Host -Object ''
	Write-Host "Adding a node to an existing SQL Server Failover Clustered Instance (FCI)..." -foregroundcolor "green"
	Write-Host -Object ''
	#Get No Of CPU On the server
	$colItems = Get-WmiObject -class "Win32_Processor" -namespace "root/CIMV2" 
	$NOfLogicalCPU = 0
	foreach ($objcpu in $colItems)
	{ $NOfLogicalCPU = $NOfLogicalCPU + $objcpu.NumberOfLogicalProcessors }
				  
	$DBSERVER = [System.Net.Dns]::GetHostName()

	#Get Rem on the server
	$mem = Get-WmiObject -Class Win32_ComputerSystem  
	$HostPhysicalMemoryGB = $($mem.TotalPhysicalMemory / 1Mb) 
	$HostPhysicalMemoryGB = [math]::floor($HostPhysicalMemoryGB)

	#List out the Initial Parameters for Users Confirmation
	$installationAccount = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
	write-host "`nServer Name is: "     -ForegroundColor yellow -NoNewline
	write-host "$DBSERVER"     -ForegroundColor green
	write-host "`nTotal CPU: " -ForegroundColor yellow -NoNewline
	write-host "$NOfLogicalCPU"      -ForegroundColor green
	write-host "`nTotal Memory: "     -ForegroundColor yellow -NoNewline
	write-host "$HostPhysicalMemoryGB"     -ForegroundColor green
	$ClusterName = Get-Cluster | Select-Object -ExpandProperty Name
	$global:FAILOVERCLUSTERNETWORKNAME = Get-ClusterResource -Name "SQL Server" | Get-ClusterParameter -Name "VirtualServerName" | select -ExpandProperty Value
	$global:SQLIP = Get-ClusterResource -Name "SQL IP*" | Get-ClusterParameter -Name "Address" | select -ExpandProperty Value
	write-host "`nSQL Server Instance Name = "     -ForegroundColor yellow -NoNewline
	write-host "$FAILOVERCLUSTERNETWORKNAME" -ForegroundColor green
	write-host "`nSQL Server Instance IP = "     -ForegroundColor yellow -NoNewline
	write-host "$SQLIP" -ForegroundColor green
	write-host "`nWindows Server Failover Cluster Name: = "     -ForegroundColor yellow -NoNewline
	write-host "$ClusterName" -ForegroundColor green 
	$ClusterIP = Get-ClusterGroup | Where-Object { $_.GroupType -eq "Cluster" } | Get-ClusterResource | Where-Object { $_.ResourceType -eq "IP Address" } |  Get-ClusterParameter -Name "Address" | Select-Object -ExpandProperty "Value"
	write-host "`nWindows Server Failover Clustering (WSFC) IP = "     -ForegroundColor yellow -NoNewline
	write-host "$ClusterIP" -ForegroundColor green
	write-host "`nAccount running the SQL Server Installation Script: =  "     -ForegroundColor yellow -NoNewline
	write-host "$installationAccount"     -ForegroundColor green
	Write-Host -Object ''
	Write-Host -Object ''
	#region commonCode
	# Execute this to ensure Powershell has execution rights
	#Set-ExecutionPolicy Unrestricted -Force
	#Set-ExecutionPolicy bypass
	#Import-Module ServerManager 
	#Add-WindowsFeature PowerShell-ISE
	sqlVersion                                    ## Calling Function
	Write-Host -Object ''
	CopyMedia                                   ## Calling Function
	Write-Host -Object ''
	#$INSTANCEDIR="C:\Program Files\Microsoft SQL Server"
	#$INSTANCEID = "MSSQLSERVER"
	$INSTANCENAME = "MSSQLSERVER"
	$FAILOVERCLUSTERGROUP = "SQL Server (MSSQLSERVER)"
	$FAILOVERCLUSTERNETWORKNAME = Get-ClusterResource -Name "SQL Server" | Get-ClusterParameter -Name "VirtualServerName" | select -ExpandProperty Value
	#Write-Host -Object ''
	#$SQLIP = Read-Host -Prompt 'Enter the SQL Server Instance IP '
	#Write-Host -Object ''
	#write-host "Cluster Network Name - " -ForegroundColor green -NoNewline
	#write-host "You can retrieve this information in the Networks section of the Failover Cluster Manager and identifying the cluster network configured with Cluster and Client. It should be in the same network range as Nodes, FCI and SQL VIP." -ForegroundColor yellow
	#Write-Host -Object ''
	$NIC = Get-ClusterResource | Where { $_.ResourceType -eq "IP Address" -and $_.OwnerGroup -eq "Cluster Group" } | Get-ClusterParameter -Name "Network" | Select-Object -ExpandProperty "Value"
	$SubnetMask = Get-ClusterResource | Where { $_.ResourceType -eq "IP Address" -and $_.OwnerGroup -eq "Cluster Group" } | Get-ClusterParameter -Name "SubnetMask" | Select-Object -ExpandProperty "Value"
	$FAILOVERCLUSTERIPADDRESSES = "IPv4;$SQLIP;$NIC;$SubnetMask"
	#$FAILOVERCLUSTERDISKS = Get-Volume | Where-Object -FilterScript { $_.DriveLetter -eq "Z" } | Select-Object -ExpandProperty "FileSystemLabel"
	Write-Host "Configure SQL Server Service Accounts:"    -ForegroundColor green
	sqlAccounts                                     ## Calling Function
	#$SQLSVCPASSWORD=Read-Host -Prompt 'Enter the Service Account Password ("In Double Quotes")'
	Write-Host -Object ''
	$AGTSVCACCOUNT = $SQLSVCACCOUNT
	$AGTSVCPASSWORD = $SQLSVCPASSWORD
	AdminAccountSQL                                     ## Calling Function
	#Write-Host -Object ''
	#$SAPWD = "sa4SQL!c"
	$UpdateSource = 'C:\Downloads\SQLUpdates'
	$SQLBackupDIR = "Z:\Backups\Disk1\sql_bak"
	#write-host "Backups Files Location is ("$SQLBackupDIR")"     -ForegroundColor green
	#Write-Host -Object ''
	#$collation = "SQL_Latin1_General_CP1_CI_AS"
	#Write-Host -Object ''
	$SQLTempDBDIR = "Z:\TempDB\Disk1\sql_dat"
	#write-host "`TEMPDB Data Files Location("$SQLTempDBDIR")"     -ForegroundColor green
	#Write-Host -Object ''
	#$SQLTEMPDBLOGDIR = "Z:\Log\Disk1\sql_log"
	#write-host "`TEMPDB Log Files Location("$SQLTEMPDBLOGDIR")"     -ForegroundColor green
	#Write-Host -Object ''
	$SQLUSERDBDIR = "Z:\Data\Disk1\sql_dat"
	#write-host "`USERs Data Files Location("$SQLUSERDBDIR")"     -ForegroundColor green
	#Write-Host -Object ''
	$SQLUSERDBLOGDIR = "Z:\Log\Disk1\sql_log"
	#write-host "`USERs Data Files Location("$SQLUSERDBLOGDIR")"     -ForegroundColor green
	#Write-Host -Object ''
	$INSTALLSQLDATADIR = "Z:\System\Disk1"
	#write-host "`USERs Data Files Location("$INSTALLSQLDATADIR")"     -ForegroundColor green
	#Write-Host -Object ''
	$SQLFEATURES = 'SQLENGINE,REPLICATION,FULLTEXT,DQC,CONN,BC,SDK,SNAC_SDK,MDS'
	#Write-Host -Object 'SQL Engine ...  '  -ForegroundColor Green
	#$SQLFEATURES=Read-Host -Prompt 'Specifies features to install, Supported values are SQLEngine, Replication, FullText, DQ, AS, AS_SPI, RS, RS_SHP, RS_SHPWFE, DQC, Conn, IS, BC, SDK, DREPLAY_CTLR, DREPLAY_CLT, SNAC_SDK, SQLODBC, SQLODBC_SDK, LocalDB, MDS, POLYBASE'
	write-host "`nSQL Instalation ready to proceed please confirm below details:"     -ForegroundColor green
	Write-Host -Object ''
	Write-Host -Object ''
	write-host "`Server Name: "     -ForegroundColor yellow -NoNewline
	write-host "$DBSERVER" -ForegroundColor green 
	Write-Host -Object ''
	write-host "Total CPU: "     -ForegroundColor yellow  -NoNewline
	write-host "$NOfLogicalCPU" -ForegroundColor green 
	Write-Host -Object ''
	write-host "Total Physical memory: "     -ForegroundColor yellow  -NoNewline
	write-host "$HostPhysicalMemoryGB MB" -ForegroundColor green 
	Write-Host -Object ''
	write-host "SQL Server Installation Media DIR = "     -ForegroundColor yellow  -NoNewline
	write-host "$SQLBinariesLocation" -ForegroundColor green 
	Write-Host -Object ''
	write-host "FEATURES: "     -ForegroundColor yellow  -NoNewline
	write-host "$SQLFEATURES" -ForegroundColor green 
	Write-Host -Object ''
	write-host "INSTANCE DIR = "     -ForegroundColor yellow  -NoNewline
	write-host "$INSTALLSQLDATADIR" -ForegroundColor green 
	Write-Host -Object ''
	write-host "Backups Files DIR = "     -ForegroundColor yellow  -NoNewline
	write-host "$SQLBACKUPDIR" -ForegroundColor green 
	Write-Host -Object ''
	write-host "USERs DATA Files DIR = "     -ForegroundColor yellow  -NoNewline
	write-host "$SQLUSERDBDIR" -ForegroundColor green 
	Write-Host -Object ''
	write-host "USERs LOG Files DIR = "     -ForegroundColor yellow  -NoNewline
	write-host "$SQLUSERDBLOGDIR" -ForegroundColor green 
	Write-Host -Object ''
	write-host "TEMPDB DATA Files DIR = "     -ForegroundColor yellow  -NoNewline
	write-host "$SQLTEMPDBDIR" -ForegroundColor green 
	Write-Host -Object ''
	write-host "SQL Server Cluster Name(Instance Name) = "     -ForegroundColor yellow  -NoNewline
	write-host "$FAILOVERCLUSTERNETWORKNAME" -ForegroundColor green
	Write-Host -Object ''
	write-host "SQL Server Instance IP = "     -ForegroundColor yellow  -NoNewline
	write-host "$SQLIP" -ForegroundColor green
	Write-Host -Object ''
	write-host "SQL Server Failover Cluster Instance = "     -ForegroundColor yellow  -NoNewline
	write-host "$FAILOVERCLUSTERGROUP" -ForegroundColor green
	#Write-Host -Object ''
	#write-host "Cluster Disk Name (Mount Disk) = "     -ForegroundColor yellow  -NoNewline
	#write-host "$FAILOVERCLUSTERDISKS" -ForegroundColor green
	Write-Host -Object ''
	write-host "Encoded FAILOVER CLUSTER IP ADDRESSES = "     -ForegroundColor yellow  -NoNewline
	write-host "$FAILOVERCLUSTERIPADDRESSES" -ForegroundColor green 
	Write-Host -Object ''
	write-host "SQL Server system administrators= "  -ForegroundColor yellow  -NoNewline
	write-host "$SQLSYSADMINACCOUNTS" -ForegroundColor green 
	Write-Host -Object ''
	write-host "Service Account (Database Services/Agent)= "  -ForegroundColor yellow  -NoNewline
	write-host "$SQLSVCACCOUNT" -ForegroundColor green 
	Write-Host -Object ''
	Write-Host -Object ''
	write-host "Press "  -ForegroundColor yellow -NoNewline
	write-host "[ENTER]"  -ForegroundColor green  -NoNewline
	write-host " to continue or "  -ForegroundColor yellow   -NoNewline
	write-host "CTRL+C"  -ForegroundColor red   -NoNewline
	write-host " to quit."  -ForegroundColor yellow
	Write-Host -Object ''

	pause

	$date = Get-Date -format "yyyy-MM-dd HH:mm:ss" 
	Write-Host -Object ''
	Write-Host "$date Starting SQL Server installation"    -ForegroundColor Green
	Write-Host -Object ''
				
	if ($version -eq "2019") {
		if ($InstanceName -eq "MSSQLSERVER") {
			Set-Location $SQLBinariesLocation
			.\setup.exe /QS /ACTION=AddNode /ENU /UpdateEnabled=1 /UpdateSource=$UpdateSource /INSTANCENAME=MSSQLSERVER /SQLSVCACCOUNT=$SQLSVCACCOUNT /SQLSVCPASSWORD=$SQLSVCPASSWORD /AGTSVCACCOUNT=$AGTSVCACCOUNT /AGTSVCPASSWORD=$AGTSVCPASSWORD /SkipRules=Cluster_VerifyForWarnings /FAILOVERCLUSTERIPADDRESSES="$FAILOVERCLUSTERIPADDRESSES" /CONFIRMIPDEPENDENCYCHANGE=0 /IACCEPTSQLSERVERLICENSETERMS
			}
		else {
			Set-Location $SQLBinariesLocation
			.\setup.exe /QS /ACTION=AddNode /ENU /UpdateEnabled=1 /UpdateSource=$UpdateSource /INSTANCENAME=$INSTANCENAME /SQLSVCACCOUNT=$SQLSVCACCOUNT /SQLSVCPASSWORD=$SQLSVCPASSWORD /AGTSVCACCOUNT=$AGTSVCACCOUNT /AGTSVCPASSWORD=$AGTSVCPASSWORD /SkipRules=Cluster_VerifyForWarnings /FAILOVERCLUSTERIPADDRESSES="$FAILOVERCLUSTERIPADDRESSES" /CONFIRMIPDEPENDENCYCHANGE=0 /IACCEPTSQLSERVERLICENSETERMS  
		}
	}
				
	if ($version -eq "2017") {
		if ($InstanceName -eq "MSSQLSERVER") {
			Set-Location $SQLBinariesLocation
			.\setup.exe /QS /ACTION=AddNode /ENU /UpdateEnabled=1 /UpdateSource=$UpdateSource /INSTANCENAME=MSSQLSERVER /SQLSVCACCOUNT=$SQLSVCACCOUNT /SQLSVCPASSWORD=$SQLSVCPASSWORD /AGTSVCACCOUNT=$AGTSVCACCOUNT /AGTSVCPASSWORD=$AGTSVCPASSWORD /SkipRules=Cluster_VerifyForWarnings /FAILOVERCLUSTERIPADDRESSES="$FAILOVERCLUSTERIPADDRESSES" /IACCEPTSQLSERVERLICENSETERMS
		}
		else {
			Set-Location $SQLBinariesLocation
			.\setup.exe /QS /ACTION=AddNode /ENU /UpdateEnabled=1 /UpdateSource=$UpdateSource /INSTANCENAME=$INSTANCENAME /SQLSVCACCOUNT=$SQLSVCACCOUNT /SQLSVCPASSWORD=$SQLSVCPASSWORD /AGTSVCACCOUNT=$AGTSVCACCOUNT /AGTSVCPASSWORD=$AGTSVCPASSWORD /SkipRules=Cluster_VerifyForWarnings /FAILOVERCLUSTERIPADDRESSES="$FAILOVERCLUSTERIPADDRESSES" /IACCEPTSQLSERVERLICENSETERMS  
		}
	}
	if ($version -eq "2016") {
		if ($InstanceName -eq "MSSQLSERVER") {
			Set-Location $SQLBinariesLocation
			.\setup.exe /QS /ACTION=AddNode /ENU /UpdateEnabled=1 /UpdateSource=$UpdateSource /INSTANCENAME=MSSQLSERVER /SQLSVCACCOUNT=$SQLSVCACCOUNT /SQLSVCPASSWORD=$SQLSVCPASSWORD /AGTSVCACCOUNT=$AGTSVCACCOUNT /AGTSVCPASSWORD=$AGTSVCPASSWORD /SkipRules=Cluster_VerifyForWarnings /FAILOVERCLUSTERIPADDRESSES="$FAILOVERCLUSTERIPADDRESSES" /IACCEPTSQLSERVERLICENSETERMS  
		}
		else {
			Set-Location $SQLBinariesLocation
			.\setup.exe /QS /ACTION=AddNode /ENU /UpdateEnabled=1 /UpdateSource=$UpdateSource /INSTANCENAME=$INSTANCENAME /SQLSVCACCOUNT=$SQLSVCACCOUNT /SQLSVCPASSWORD=$SQLSVCPASSWORD /AGTSVCACCOUNT=$AGTSVCACCOUNT /AGTSVCPASSWORD=$AGTSVCPASSWORD /SkipRules=Cluster_VerifyForWarnings /FAILOVERCLUSTERIPADDRESSES="$FAILOVERCLUSTERIPADDRESSES" /IACCEPTSQLSERVERLICENSETERMS  
		}
	}
	elseif ($version -eq "2014") {
		if ($InstanceName -eq "MSSQLSERVER") {
			Set-Location $SQLBinariesLocation
			.\setup.exe /QS /ACTION=AddNode /ENU /UpdateEnabled=1 /UpdateSource=$UpdateSource /INSTANCENAME=MSSQLSERVER /SQLSVCACCOUNT=$SQLSVCACCOUNT /SQLSVCPASSWORD=$SQLSVCPASSWORD /AGTSVCACCOUNT=$AGTSVCACCOUNT /AGTSVCPASSWORD=$AGTSVCPASSWORD /SkipRules=Cluster_VerifyForWarnings /FAILOVERCLUSTERIPADDRESSES="$FAILOVERCLUSTERIPADDRESSES" /IACCEPTSQLSERVERLICENSETERMS  
		}
		else {
			Set-Location $SQLBinariesLocation
			.\setup.exe /QS /ACTION=AddNode /ENU /UpdateEnabled=1 /UpdateSource=$UpdateSource /INSTANCENAME=$INSTANCENAME /SQLSVCACCOUNT=$SQLSVCACCOUNT /SQLSVCPASSWORD=$SQLSVCPASSWORD /AGTSVCACCOUNT=$AGTSVCACCOUNT /AGTSVCPASSWORD=$AGTSVCPASSWORD /SkipRules=Cluster_VerifyForWarnings /FAILOVERCLUSTERIPADDRESSES="$FAILOVERCLUSTERIPADDRESSES" /IACCEPTSQLSERVERLICENSETERMS  
		}
	}

	if ($InstanceName -eq "MSSQLSERVER") {
		$service = Get-WmiObject -Class Win32_Service -Filter "Name='MSSQLSERVER'"
	}
	else {
		$service = Get-WmiObject -Class Win32_Service -Filter "Name='$InstanceName'"
	}
	if (!($service.Name)) {
		Write-Host -Object ''
		Write-Host "SQL Service not found" -foregroundcolor "red"
		# Get setup failure message from summary.txt file
		switch ($version) { 
			"2019" { [string]$SQLVerNo = "150" } 
			"2017" { [string]$SQLVerNo = "140" } 
			"2016" { [string]$SQLVerNo = "130" } 
			"2014" { [string]$SQLVerNo = "120" } 
			"2012" { [string]$SQLVerNo = "110" } 
		}

		Write-Host -Object ''
		$SQLInstallationSummary = "$env:programfiles\Microsoft SQL Server\$SQLVerNo\Setup Bootstrap\Log\Summary.txt"

		if (!(test-path $SQLInstallationSummary)) { write-host -ForegroundColor Red "`nSummary file does not exists, setup failed for some basic reason, pleaes check this file location $SQLInstallationSummary"; exit }


		$SQLSetupErrorMessage = gc $SQLInstallationSummary | ? { ($_ | Select-String "Exit message:") }  
		if ($SQLSetupErrorMessage) { write-host ($SQLSetupErrorMessage.Replace("Exit message:", "") + "`n `n" + "For detiled error message check `n$SQLInstallationSummary`n") -foregroundcolor "red"; exit }
		else { write-host "Could not find SQL setup summary log file" -foregroundcolor "red" }
	}
	else {
		Write-Host "`nSQL Service found, Installation completed Successfully!!!" -foregroundcolor "green"
		# Get setup failure message from summary.txt file
		switch ($version) { 
			"2019" { [string]$SQLVerNo = "150" } 
			"2017" { [string]$SQLVerNo = "140" } 
			"2016" { [string]$SQLVerNo = "130" } 
			"2014" { [string]$SQLVerNo = "120" } 
			"2012" { [string]$SQLVerNo = "110" } 
		}

		Write-Host -Object ''
		$SQLInstallationSummary = "$env:programfiles\Microsoft SQL Server\$SQLVerNo\Setup Bootstrap\Log\Summary.txt"

		if (!(test-path $SQLInstallationSummary)) {
			write-host -ForegroundColor Red "`nSummary file does not exists, pleaes check the default Installation Log Summary File Location - " -nonewline
			write-host -ForegroundColor yellow "`C:\Program Files\Microsoft SQL Server\<SQLVerNo>\Setup Bootstrap\LOG\Summary.txt"
		}
		else {
			write-host -ForegroundColor yellow "`nPlease review $SQLInstallationSummary file for installation status of SQL Server components."
			Write-Host -Object ''		
			notepad.exe $SQLInstallationSummary
		}
	}
}

Function SSMSInstallationTask {
	if ((Get-WmiObject Win32_ComputerSystem).Domain -eq "domain.com") {
		Write-Host -Object ''
		Write-Host -Object 'SQL Server Management Studio (SSMS) Installation:' -ForegroundColor Green
		Write-Host -Object ''
		# Set file and folder path for SSMS installer .exe
		$Default = 'C:\Downloads\SQLUpdates'
		Write-Host -Object ''
		if (!($folderpath = Read-Host -Prompt 'Enter the Download Location [C:\Downloads\SQLUpdates]')) { $folderpath = $Default }
		Write-Host -Object ''
		$filepath = "$folderpath\SSMS-Setup-ENU.exe"
		#If SSMS not present, download
		if (!(Test-Path $filepath)) {
			Write-Host -Object ''
			Write-Host -Object 'Copying the Latest SQL Server Management Studio (SSMS) to '  -ForegroundColor green -nonewline
			Write-Host -Object 'C:\Downloads\SQLUpdates'  -ForegroundColor yellow -nonewline
			Write-Host -Object ' Please Allow some time...  '  -ForegroundColor green
			robocopy "\\cssumitwhq4\CSMDBA\DB\SQLInstall\SSMS" "C:\Downloads\SQLUpdates" /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /log:C:\temp\SSMS-Setup.log
			Write-Host -Object ''
			Write-Host "SSMS installer Copied to local host, please review log file." -ForegroundColor Green
			Write-Host -Object ''
		}
		else {
			Write-Host -Object ''
			write-host "Located the SQL SSMS Installer binaries, moving on to install..."
			Write-Host -Object ''
		}
				 
		# start the SSMS installer
		write-host "Beginning SQL Server Management Studio (SSMS) install..." -nonewline
		$Parms = " /Install /QS /Norestart /Logs log.txt"
		$Prms = $Parms.Split(" ")
		& "$filepath" $Prms | Out-Null
		Write-Host "SSMS installation complete" -ForegroundColor Green
		pause
		sqlPostInstallation
	}	
	elseif ((Get-WmiObject Win32_ComputerSystem).Domain -eq "domain_2.com") {
		Write-Host -Object ''
		Write-Host -Object 'SQL Server Management Studio (SSMS) Installation:' -ForegroundColor Green
		Write-Host -Object ''
		# Set file and folder path for SSMS installer .exe
		$Default = 'C:\Downloads\SQLUpdates'
		Write-Host -Object ''
		if (!($folderpath = Read-Host -Prompt 'Enter the Download Location [C:\Downloads\SQLUpdates]')) { $folderpath = $Default }
		Write-Host -Object ''
		$filepath = "$folderpath\SSMS-Setup-ENU.exe"
		#If SSMS not present, download
		if (!(Test-Path $filepath)) {
			Write-Host -Object ''
			Write-Host -Object 'Copying the Latest SQL Server Management Studio (SSMS) to '  -ForegroundColor green -nonewline
			Write-Host -Object 'C:\Downloads\SQLUpdates'  -ForegroundColor yellow -nonewline
			Write-Host -Object ' Please Allow some time...  '  -ForegroundColor green
			robocopy "\\cs-softwarelocation\ASPSQL_CSM\SQLInstall\SSMS" "C:\Downloads\SQLUpdates" /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /log:C:\temp\SSMS-Setup.log
			Write-Host -Object ''
			Write-Host "SSMS installer Copied to local host, please review log file." -ForegroundColor Green
			Write-Host -Object ''
		}
		else {
			Write-Host -Object ''
			write-host "Located the SQL SSMS Installer binaries, moving on to install..."
			Write-Host -Object ''
		}
				 
		# start the SSMS installer
		write-host "Beginning SQL Server Management Studio (SSMS) install..." -nonewline
		$Parms = " /Install /QS /Norestart /Logs log.txt"
		$Prms = $Parms.Split(" ")
		& "$filepath" $Prms | Out-Null
		Write-Host "SSMS installation complete" -ForegroundColor Green
		pause
		sqlPostInstallation
	}
	else {
		Write-Host -Object ''
		Write-Host -Object 'SQL Server Management Studio (SSMS) Installation:' -ForegroundColor Green
		Write-Host -Object ''
		# Set file and folder path for SSMS installer .exe
		$Default = 'C:\Downloads\SQLUpdates'
		Write-Host -Object ''
		if (!($folderpath = Read-Host -Prompt 'Enter the Download Location [C:\Downloads\SQLUpdates]')) { $folderpath = $Default }
		Write-Host -Object ''
		$filepath = "$folderpath\SSMS-Setup-ENU.exe"
		#If SSMS not present, download
		if (!(Test-Path $filepath)) {
			Write-Host -Object ''
			Write-Host -Object 'Copying the Latest SQL Server Management Studio (SSMS) to '  -ForegroundColor green -nonewline
			Write-Host -Object 'C:\Downloads\SQLUpdates'  -ForegroundColor yellow -nonewline
			Write-Host -Object ' Please Allow some time...  '  -ForegroundColor green
			robocopy "\\cs-softwarelocation\ASPSQL_CSM\SQLInstall\SSMS" "C:\Downloads\SQLUpdates" /E /Z /ZB /R:5 /W:5 /TBD /NP /V /MT:16 /log:C:\temp\SSMS-Setup.log
			Write-Host -Object ''
			Write-Host "SSMS installer Copied to local host, please review log file." -ForegroundColor Green
			Write-Host -Object ''
		}
		else {
			Write-Host -Object ''
			write-host "Located the SQL SSMS Installer binaries, moving on to install..."
			Write-Host -Object ''
		}
				 
		# start the SSMS installer
		write-host "Beginning SQL Server Management Studio (SSMS) install..." -nonewline
		$Parms = " /Install /QS /Norestart /Logs log.txt"
		$Prms = $Parms.Split(" ")
		& "$filepath" $Prms | Out-Null
		Write-Host "SSMS installation complete" -ForegroundColor Green
		pause
		sqlPostInstallation
	}
}

Function Configurequorum {
	do {
		Write-Host -Object ''
		Write-Host -Object 'Configure and Manage Quorum' -ForegroundColor yellow
		Write-Host -Object ''
		$ClusterQuorum = Read-Host -Prompt 'Select Options to Proceed [1] - Disk Quorum [2] - FileShare Witness [3] - NodeMajority'
		switch ($ClusterQuorum) {
			1 {
				QuorumDiskCreation
				MountPointChecks
				Write-Host -Object ''
				$DefaultMount = 'Quorum' 
				if (!($QuorumDiskLabel = Read-Host -Prompt 'Enter the Disk Name [Quorum]')) { $QuorumDiskLabel = $DefaultMount }
				Write-Host -Object ''
				Set-ClusterQuorum -DiskWitness $QuorumDiskLabel
				Write-Host -Object ''
				Pause
				Write-Host -Object ''
				sqlPostInstallation
			}
			2 {
				Write-Host -Object ''
				$QuorumFileShare = Read-Host -Prompt 'Enter the FileShare Location'
				Write-Host -Object ''
				Set-ClusterQuorum -NodeAndFileShareMajority $QuorumFileShare
				Write-Host -Object ''
				Pause
				Write-Host -Object ''
				sqlPostInstallation
			}
			3 {
				$ClusterNodesCount = (Get-ClusterNode).name.count
				$Result = $ClusterNodesCount % 2
				if ($Result -eq 0) {
					Write-Host -Object '' 
					write-host "Total $ClusterNodesCount Nodes are under this Cluster, Node Majority is Only recommended for clusters with an odd number of nodes. Please try Disk Disk Quorum or Fileshare Witness in this case." -ForegroundColor Yellow
					Write-Host -Object '' 
					pause
					Configurequorum
				}
				else 
				{ Set-ClusterQuorum -NodeMajority }
				Write-Host -Object ''
				Pause
				Write-Host -Object ''
				sqlPostInstallation				
			}
			default {
				$errout = 'Invalid option please try again........'
			}
		}
	}
	until ($ClusterQuorum -ne '')
}

Function sqlPostInstallation {
	Clear-Host        
	Do {
		Clear-Host
		Write-Host ("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++") -ForegroundColor cyan
		Write-Host ("+                SQL.Next ==> SQL Server Automation                +")  -ForegroundColor cyan
		Write-Host ("+                    Written By: SUMIT KUMAR                       +") -ForegroundColor cyan
		Write-Host ("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++") -ForegroundColor cyan
		Write-Host ("!!             	                                                  !!") -ForegroundColor cyan
		Write-Host ("!!             	                                                  !!") -ForegroundColor cyan
		Write-Host ("--------------------------------------------------------------------") -ForegroundColor cyan
		Write-Host ("!!                    SQL Server Post Installation                !!") -ForegroundColor cyan
		Write-Host ("--------------------------------------------------------------------")    -ForegroundColor cyan
		Write-Host ("!!             	                                                  !!") -ForegroundColor cyan
		Write-Host ******************************************************************** -ForegroundColor cyan
		Write-Host ("                                                                    ")  -ForegroundColor cyan
		Write-Host ******************************************************************** -ForegroundColor cyan
		Write-Host -Object '' 
		Write-Host -Object '' 
		Write-Host -Object '1. SSMS Installation:'
		Write-Host -Object ''
		Write-Host -Object '2. SQL Server Monitoring Jobs:'
		Write-Host -Object ''
		Write-Host -Object '3. Zabbix Configuration:'
		Write-Host -Object ''
		Write-Host -Object '4. Backups Policies: '
		Write-Host -Object ''
		Write-Host -Object '5. Configure Quorum'
		Write-Host -Object ''
		Write-Host -Object '6. Main Menu'
		Write-Host -Object $errout
		$sqlPostInstallation = Read-Host -Prompt 'Please Select an Option to Proceed(1-6)'
 
		switch ($sqlPostInstallation) {
			1 {
				SSMSInstallationTask            
			}
			2 {
				sqlMonitoring
			}
			3 {
				zabbixConfiguration
			}
			4 {
				sqlbackupsPolicies
			}
			5 {
				Configurequorum
			} 
			6 {
				Menu
			}   
			default {
				$errout = 'Invalid option please try again........'
			}
 
		}
	}
	until ($sqlPostInstallation -ne '')
}


Function uninstallSQLServer {
	$SQLFEATURES = 'SQLENGINE,REPLICATION,FULLTEXT,DQC,CONN,BC,SDK,SNAC_SDK,MDS'
	$INSTANCENAME = "MSSQLSERVER"
	$DBSERVER = [System.Net.Dns]::GetHostName()
	Write-Host -Object ''
	Write-Host -Object 'Uninstall an Existing Instance of SQL Server? '  -ForegroundColor yellow
	Write-Host -Object ''
	$global:SQLBinariesLocation = Read-Host -Prompt 'Enter the Path for SQL Server Binaries'
	$global:FAILOVERCLUSTERNETWORKNAME = Get-ClusterResource -Name "SQL Server" | Get-ClusterParameter -Name "VirtualServerName" | select -ExpandProperty Value
	if ((($SQLBinariesLocation | measure).count -eq 0) -or ($SQLBinariesLocation -eq "")) {
		Write-Host -Object ''
		Write-Host "Please Enter a valid Destination path of SQL Server Media"  -ForegroundColor red
		Write-Host -Object ''
		pause
		RemoveNodeCluster
	}
	else {
		write-host "`nReady to Uninstall SQL Server, please confirm below details and hit Enter:"     -ForegroundColor green
		Write-Host -Object ''
		write-host "`Server Name: "     -ForegroundColor yellow -NoNewline
		write-host "$DBSERVER" -ForegroundColor green 
		Write-Host -Object ''
		write-host "`Instance Name (Default Instance): "     -ForegroundColor yellow -NoNewline
		write-host "$INSTANCENAME" -ForegroundColor green 
		Write-Host -Object ''
		write-host "SQL Server Failover Cluster Name "     -ForegroundColor yellow -NoNewline
		write-host "$FAILOVERCLUSTERNETWORKNAME" -ForegroundColor green
		Write-Host -Object ''
		write-host "Press "  -ForegroundColor yellow -NoNewline
		write-host "[ENTER]"  -ForegroundColor green  -NoNewline
		write-host " to continue or "  -ForegroundColor yellow -NoNewline
		write-host "CTRL+C"  -ForegroundColor red   -NoNewline
		write-host " to quit."  -ForegroundColor yellow
		Write-Host -Object ''
		pause
		Write-Host -Object ''
		Write-Host -Object 'Removing Node from Cluster, Please Allow some time...  '  -ForegroundColor green
		Write-Host -Object ''
		Set-Location $SQLBinariesLocation
		.\setup /QS /ACTION=RemoveNode /INSTANCENAME=MSSQLSERVER /FAILOVERCLUSTERNETWORKNAME=$FAILOVERCLUSTERNETWORKNAME /CONFIRMIPDEPENDENCYCHANGE=0
		Write-Host -Object ''
	}
}


Function Menu {
	Clear-Host       
	Do {
		Clear-Host
		Write-Host ("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++") -ForegroundColor cyan
		Write-Host ("+                SQL.Next ==> SQL Server Automation                +")  -ForegroundColor cyan
		Write-Host ("+                    Written By: SUMIT KUMAR                       +") -ForegroundColor cyan
		Write-Host ("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++") -ForegroundColor cyan
		Write-Host ("!!             	                                                  !!") -ForegroundColor cyan
		Write-Host ("!!             	                                                  !!") -ForegroundColor cyan
		Write-Host ("--------------------------------------------------------------------") -ForegroundColor cyan
		Write-Host ("!!                        M A I N  M E N U                        !!") -ForegroundColor cyan
		Write-Host ("--------------------------------------------------------------------")    -ForegroundColor cyan
		Write-Host ("!!             	                                                  !!") -ForegroundColor cyan
		Write-Host ******************************************************************** -ForegroundColor cyan
		Write-Host ("                                                                    ")  -ForegroundColor cyan
		Write-Host ******************************************************************** -ForegroundColor cyan
		Write-Host -Object ''
		Write-Host -Object '' 
		Write-Host -Object '    1. Pre-checks '
		Write-Host -Object ''
		Write-Host -Object '    2. Create Disks '
		Write-Host -Object ''
		Write-Host -Object '    3. SQL Server Installation - Cluster'
		Write-Host -Object ''
		Write-Host -Object '    4. Post Installation Tasks'
		Write-Host -Object ''
		Write-Host -Object '    5. Uninstall SQL Server'
		Write-Host -Object ''
		Write-Host -Object '    6. Exit'
		Write-Host -Object $errout
		$Menu = Read-Host -Prompt 'Please Choose an option (1-6)'
 
		switch ($Menu) {
			1 {
				sqlClusterPreCheckTasks            
			}
			2 {
				CreateDisksTask
			}
			3 {
				sqlInstallationTask
			}
			4 {
				sqlPostInstallation
			}
			5 {
				uninstallSQLServer
			}
			6 {
				return
			}
			default {
				$errout = 'Invalid option please try again........'
			}
 
		}
	}
	until ($Menu -ne '')
}

Menu
