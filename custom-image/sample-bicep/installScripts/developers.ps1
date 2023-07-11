## Install Script for Developer Images

## Tooling List removing  'ruby', (install issue with packer)
$tools = @(
            'jq', 'PyCharm-community','pycharm-professional' , 'anaconda3', 'Python3',
             'Rust' ,'golang' ,'nodejs',  'php','ruby',	 'docker-engine', 'docker' 
        )

## Install Tools using Chocolatey from the list above
foreach ($tool in $tools) {
    choco install $tool -y --no-progress
    Write-Host "Installed the tool: $tool"
}

choco install Containers Microsoft-Hyper-V --source windowsfeatures -y --no-progress

## Chocolatey Logs
$chocolateyLogs = 'C:\ProgramData\chocolatey\logs\chocolatey.log'
#Write-Output '## Chocolatey Installation Logs:'
#Get-Content -Path $chocolateyLogs

if  ( $LASTEXITCODE -eq 1010 -or $LASTEXITCODE  -eq 3010 )  {
	write-host " !! pending reboot !! overriding return code with 0" 
    $LASTEXITCODE=0
    $global:LASTEXITCODE=0
    $script:LASTEXITCODE=0
exit 0
}
