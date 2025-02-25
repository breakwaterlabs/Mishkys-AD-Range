﻿$ErrorActionPreference = Stop
$VMStuff="C:\VM_Stuff_Share"
$IsoSavePath = "$VMStuff\ISOs\Windows Server 2022 (20348.169.210806-2348.fe_release_svc_refresh_SERVER_EVAL_x64FRE_en-us).iso"
$VMSwitchName = "Testing"

Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
Install-PackageProvider Nuget –force –verbose
# Install all modules up front before lengthy download
$RequiredModules = @(
    "PowerShellGet"
    "Hyper-V"
    "Convert-WindowsImage"
)
foreach ($module in $RequiredModules) {
    Install-Module –Name $module –Force –Verbose
}

try {
    set-vmswitch $VMSwitchName -AllowManagementOS $true -verbose
} catch [Microsoft.HyperV.PowerShell.VirtualizationException] {
    if ($_.Exception.message -like "Hyper-V was unable to find a virtual switch with name *")  {
        $Adapter = (get-netadapter | where-object {$_.virtual -eq $false -and $_.MediaConnectionState -eq "Connected" -and $_.AdminStatus -eq "Up" -and $_.status -eq "Up"})[0]
        new-vmswitch -name $VMSwitchName -NetAdapterName $Adapter.name -AllowManagementOS $true -verbose
        write-host "Created new VMSwitch '$VMSwitchName' on adapter '$($adapter.name)'"
    } else {
        throw $_
    }
}


New-Item $VMStuff\Lab -ItemType Directory -force
New-Item $VMStuff\ISOs -ItemType Directory -force
Set-Location $VMStuff\ISOs

# avoid re-downloading unnecessarily asscript may need to be re-run elevated and we don't want to trigger an overwrite / re-download of 5GB for no reason
if (-not (test-path $isoSavePath)) {
    Invoke-WebRequest -Uri "https://software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/SERVER_EVAL_x64FRE_en-us.iso" -OutFile $IsoSavePath
}

Write-Host "Grab a x64 ISO from https://www.microsoft.com/en-us/evalcenter/download-windows-server-2022 and save it in the ISOs folder."
Write-Host "If the above fails to install Convert-WindowsImage then download it from https://github.com/x0nn/Convert-WindowsImage"
Write-Host "Save it in $VMStuff\Convert-WindowsImage (from PS Gallery)"
