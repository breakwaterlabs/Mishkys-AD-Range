$ErrorActionPreference = Stop
$VMStuff="C:\VM_Stuff_Share"
$IsoSavePath = "$VMStuff\ISOs\Windows Server 2022 (20348.169.210806-2348.fe_release_svc_refresh_SERVER_EVAL_x64FRE_en-us).iso"

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


New-VMSwitch -Name "Testing" -NetAdapterName "Ethernet" ; Set-VMSwitch -Name Testing -AllowManagementOS $true
New-Item $VMStuff\Lab -ItemType Directory
New-Item $VMStuff\ISOs -ItemType Directory
Set-Location $VMStuff\ISOs

# avoid re-downloading unnecessarily asscript may need to be re-run elevated and we don't want to trigger an overwrite / re-download of 5GB for no reason
if (-not (test-path $isoSavePath)) {
    Invoke-WebRequest -Uri "https://software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/SERVER_EVAL_x64FRE_en-us.iso" -OutFile $IsoSavePath
}

Write-Host "Grab a x64 ISO from https://www.microsoft.com/en-us/evalcenter/download-windows-server-2022 and save it in the ISOs folder."

Install-Module -Name Convert-WindowsImage

Write-Host "If the above fails to install Convert-WindowsImage then download it from https://github.com/x0nn/Convert-WindowsImage"
Write-Host "Save it in $VMStuff\Convert-WindowsImage (from PS Gallery)"
