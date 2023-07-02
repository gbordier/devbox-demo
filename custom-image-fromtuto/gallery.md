## part 1 -- az cli sample to list devcenter assets

devcenter=$(az devcenter admin devcenter list --query "[].name" -o tsv )
az devcenter admin devbox-definition list --dev-center-name $devcenter --resource-group=devenvnet
microsoftwindowsdesktop_windows-ent-cpc_win10-22h2-ent-cpc-os"

## check available offers

Get-AzVMImageOffer -Location westeurope -PublisherName MicrosoftWindowsDesktop

## check available skus

Get-AzVMImageSku -Location westeurope -PublisherName MicrosoftWindowsDesktop -Offer "windows-10"
Get-AzVMImageSku -Location westeurope -PublisherName MicrosoftWindowsDesktop -Offer "windows-ent-cpc"
Get-AzVMImage -Location westeurope -PublisherName MicrosoftWindowsDesktop -Offer "windows-ent-cpc" -sku win10-22h2-ent-cpc-os

<H1> initialize variable  </H1>

# prereqs.

Register-AzResourceProvider -ProviderNamespace Microsoft.VirtualMachineImages

'Az.ImageBuilder', 'Az.ManagedServiceIdentity' | ForEach-Object {Install-Module -Name $\_ -AllowPrerelease}

$resourcegroupname="devenvnet"
$subscriptionID=$currentAzContext.Subscription.Id
$imageResourceGroup=$resourcegroupname
$location="westeurope"
$runOutputName="aibCustWinManImg01"

$imageTemplateName="vscodeWinTemplate"


## vriables

# Get existing context

$currentAzContext = Get-AzContext




# Image distribution metadata reference name


## create MI

# Set up role def names, which need to be unique

$timeInt=$(get-date -UFormat "%s")
$imageRoleDefName="Azure Image Builder Image Def"+$timeInt
$identityName="aibIdentity"+$timeInt


## is User Assigned Identity has already neen created :
$identityName="MI-DEV-TEST"

## Add an Azure PowerShell module to support AzUserAssignedIdentity

Install-Module -Name Az.ManagedServiceIdentity

# Create an identity

New-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName -Location $location

$identityNameResourceId=$(Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName).Id 
$identityNamePrincipalId=$(Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName).PrincipalId

## assign the MI to gallery [[limit to current resource group]]

$aibRoleImageCreationUrl="https://raw.githubusercontent.com/azure/azvmimagebuilder/master/solutions/12_Creating_AIB_Security_Roles/aibRoleImageCreation.json" 
$aibRoleImageCreationPath = "aibRoleImageCreation.json"

# Download the configuration

Invoke-WebRequest -Uri $aibRoleImageCreationUrl -OutFile $aibRoleImageCreationPath -UseBasicParsing 
((Get-Content -path $aibRoleImageCreationPath -Raw) -replace '<subscriptionID>',$subscriptionID) | Set-Content -Path $aibRoleImageCreationPath
((Get-Content -path $aibRoleImageCreationPath -Raw) -replace '<rgName>', $imageResourceGroup) | Set-Content -Path $aibRoleImageCreationPath
((Get-Content -path $aibRoleImageCreationPath -Raw) -replace 'Azure Image Builder Service Image Creation Role', $imageRoleDefName) | Set-Content -Path $aibRoleImageCreationPath

# Create a role definition

New-AzRoleDefinition -InputFile ./aibRoleImageCreation.json

# Grant the role definition to the VM Image Builder service principal

New-AzRoleAssignment -ObjectId $identityNamePrincipalId -RoleDefinitionName $imageRoleDefName -Scope "/subscriptions/$subscriptionID/resourceGroups/$imageResourceGroup"

## create gallery

# Gallery name

$galleryName= "devboxGallery"

# Image definition name

$imageDefName ="vscodeImageDef"

# Additional replication region

$replRegion2="northeurope"

# Create the gallery

New-AzGallery -GalleryName $galleryName -ResourceGroupName $imageResourceGroup -Location $location

$SecurityType = @{Name='SecurityType';Value='TrustedLaunch'}  
$features = @($SecurityType)

# Create the image definition

New-AzGalleryImageDefinition -GalleryName $galleryName -ResourceGroupName $imageResourceGroup -Location $location -Name $imageDefName -OsState generalized -OsType Windows -Publisher 'myCompany' -Offer 'vscodebox' -Sku '1-0-0' -Feature $features -HyperVGeneration "V2"

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
"runElevated" : true,
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
]
}
],
"distribute":
[
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

$templateFilePath=".\tmpl.json"
$templ=$templ -replace '<subscriptionID>',$subscriptionID
$templ=$templ -replace '<rgName>',$imageResourceGroup
$templ=$templ -replace '<runOutputName>',$runOutputName
$templ=$templ -replace '<imageDefName>',$imageDefName
$templ=$templ -replace '<sharedImageGalName>',$galleryName
$templ=$templ -replace '<region1>',$location 
$templ=$templ -replace '<region2>',$replRegion2
$templ = $templ  -replace '<imgBuilderId>',$identityNameResourceId
$templ | Set-Content -path $templateFilePath


New-AzResourceGroupDeployment -ResourceGroupName $imageResourceGroup -TemplateFile $templateFilePath -Api-Version "2020-02-14" -imageTemplateName $imageTemplateName -svclocation $location

Invoke-AzResourceAction -ResourceName $imageTemplateName -ResourceGroupName $imageResourceGroup -ResourceType Microsoft.VirtualMachineImages/imageTemplates -ApiVersion "2020-02-14" -Action Run

while ((Get-AzImageBuilderTemplate -ResourceGroupName $imageResourceGroup ).LastRunStatusRunState -ieq "Running") { write-host "running" ; sleep 300 }





missing :
Perl
JS
Angular

C

C#
