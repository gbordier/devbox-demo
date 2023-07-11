## Install Script for common organisation tooling

## Chocolatey Install
Set-ExecutionPolicy Bypass -Scope Process -Force; 
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))


## Tooling List
$tools = @(
            "vscode", "7zip", "azcopy10", "azure-cli", 
             "gh", "git", "github-desktop", 'pwsh' ,'wsl'
        )


## Install Tools using Chocolatey from the list above
foreach ($tool in $tools) {
    choco install $tool -y  --no-progress 
    Write-Host "Installed the tool: $tool"
}

if  ( $LASTEXITCODE -eq 1010 -or $LASTEXITCODE  -eq 3010 )  {
	write-host " !! pending reboot !! overriding return code with 0" 
    $global:LASTEXITCODE=0
    $script:LASTEXITCODE=0
exit 0
}

## VsCode Extensions
## https://community.chocolatey.org/packages?q=vscode