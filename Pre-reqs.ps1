$ErrorActionPreference = "Stop"
$VMStuff="C:\VM_Stuff_Share"
$IsoSavePath = "$VMStuff\ISOs\Windows Server 2022 (20348.169.210806-2348.fe_release_svc_refresh_SERVER_EVAL_x64FRE_en-us).iso"
$VMSwitchName = "Testing"

Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All


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

@("Lab", "ISOs") | foreach-object {New-Item "$VMStuff\$_" -ItemType Directory -force | out-null}
Set-Location $VMStuff\ISOs

# avoid re-downloading unnecessarily asscript may need to be re-run elevated and we don't want to trigger an overwrite / re-download of 5GB for no reason
if (-not (test-path $isoSavePath)) {
    write-host "ISO previously downloaded; If you have issues please delete it and re-run to re-download the file."
} else {
    try {
        Invoke-WebRequest -Uri "https://1software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/SERVER_EVAL_x64FRE_en-us.iso" -OutFile $IsoSavePath
    } catch {
        Write-Host "ISO download failed, please downlod a x64 ISO from https://www.microsoft.com/en-us/evalcenter/download-windows-server-2022 and save it in the ISOs folder.`r`n($ISOSavePath)"
    }
}
write-host "ISO saved under $ISOSavePath."

invoke-webrequest -uri "https://raw.githubusercontent.com/x0nn/Convert-WindowsImage/refs/heads/main/Convert-WindowsImage.ps1" -outfile "$VMStuff\Lab\Convert-WindowsImage.ps1" -verbose
