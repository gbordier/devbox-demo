Param ([switch] $force)

. .\0-variables.ps1



$templ=@'
{
    "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "imageTemplateName": {
            "type": "string"
        },
        "api-version": {
            "type": "string"
        },
        "svclocation": {
            "type": "string"
        }
    },
    "variables": {},
    "resources": [
        {
            "name": "[parameters('imageTemplateName')]",
            "type": "Microsoft.VirtualMachineImages/imageTemplates",
            "apiVersion": "[parameters('api-version')]",
            "location": "[parameters('svclocation')]",
            "dependsOn": [],
            "tags": {
                "imagebuilderTemplate": "win11multi",
                "userIdentity": "enabled"
            },
            "identity": {
                "type": "UserAssigned",
                "userAssignedIdentities": {
                    "<imgBuilderId>": {}
                }
            },
            "properties": {
                "buildTimeoutInMinutes": 400,
                "vmProfile": {
                    "vmSize": "Standard_DS4_v2",
                    "osDiskSizeGB": 127
                },
                "source": {
                    "type": "PlatformImage",
                    "publisher": "MicrosoftWindowsDesktop",
                    "offer": "windows-ent-cpc",
                    "sku": "win10-22h2-ent-cpc-os",
                    "version": "latest"
                },
                "customize": [
                    {
                        "type": "PowerShell",
                        "name": "Install Choco and Vscode",
                        "runElevated": true,
                        "inline": [
                            "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))",
                            "choco install vscode wsl git azure-cli -y --no-progress",
                            "choco install PyCharm-community pycharm-professional -y --no-progress",
                            "choco install anaconda3 Python3 Rust golang nodejs ruby php -y --no-progress",
                            "choco install Containers Microsoft-Hyper-V --source windowsfeatures -y --no-progress",
                            "choco install docker-engine docker -y --no-progress"
                        ]
                    },
                    {
                        "type": "WindowsRestart"
                    }
                ],
                "distribute": [
                    {
                        "type": "SharedImage",
                        "galleryImageId": "/subscriptions/<subscriptionID>/resourceGroups/<rgName>/providers/Microsoft.Compute/galleries/<sharedImageGalName>/images/<imageDefName>",
                        "runOutputName": "<runOutputName>",
                        "artifactTags": {
                            "source": "azureVmImageBuilder",
                            "baseosimg": "win10multi"
                        },
                        "replicationRegions": [
                            "<region1>",
                            "<region2>"
                        ]
                    }
                ]
            }
        }
    ]
}
'@

if (!(test-path ".\output")) { mkdir ".\output"}
$templateFilePath=".\output\customizedtemplate.json"
$templ=$templ -replace '<subscriptionID>',$subscriptionID
$templ=$templ -replace '<rgName>',$imageResourceGroup
$templ=$templ -replace '<runOutputName>',$runOutputName
$templ=$templ -replace '<imageDefName>',$imageDefName
$templ=$templ -replace '<sharedImageGalName>',$galleryName
$templ=$templ -replace '<imgBuilderId>',$identityNameResourceId
$templ=$templ -replace '<region1>',$location 
$templ=$templ -replace '<region2>',$replRegion2

$templ | Set-Content -path $templateFilePath

