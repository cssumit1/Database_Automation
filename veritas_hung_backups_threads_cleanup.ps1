if($Null -eq (get-process "bp*" -ea SilentlyContinue)){ 
    Write-Output "bp* threads not Running" 
}

else{ 
   Write-Output "bp* threads Running"
   Stop-Process -processname "bp*" -Force
   Write-Output "Stopped bp* threads"
}


if($Null -eq (get-process "*dbback*" -ea SilentlyContinue)){ 
    Write-Output "bp* threads not Running" 
}

else{ 
   Write-Output "bp* threads Running"
   Stop-Process -processname "*dbback*" -Force
   Write-Output "Stopped dbback* threads"
}

if($Null -eq (get-process "*backup*" -ea SilentlyContinue)){ 
    Write-Output "*backup* threads not Running" 
}

else{ 
   Write-Output "*backup* threads Running"
   Stop-Process -processname "*backup*" -Force
   Write-Output "Stopped backup threads"
}


if($Null -eq (get-process "*bpcd*" -ea SilentlyContinue)){ 
    Write-Output "*bpcd* Not Running" 
}

else{ 
   Write-Output "*bpcd* thread are Running"
   Stop-Process -processname "*bpcd*" -Force
   Write-Output "Stopped *bpcd* threads"
}


if($Null -eq (get-process "progress" -ea SilentlyContinue)){ 
    Write-Output "progress.exe Not Running" 
}

else{ 
   Write-Output "Progress is Running"
   Stop-Process -processname "progress"
   "Stopped *progress.exe*"
}



if($Null -eq (get-service "VRTSpbx" -ea SilentlyContinue)){ 
       Write-Output "VRTSpbx NetBackup Services Not Running" 
}

else{ 
   Write-Output "VRTSpbx NetBackup Services is Running"
   Stop-service -servicename "VRTSpbx" -Force
   Write-Output "VRTSpbx stoped"

   start-service -servicename "VRTSpbx"
   Write-Output "Started VRTSpbx NetBackup Services"
   start-service -servicename "NetBackup Client Service"
      Write-Output "VRTSpbx NetBackup Services Restarted"
}

Write-Output "Current NetBackup Services Status:"

Get-Service "VRTSpbx"
Get-Service "NetBackup Client Service"
