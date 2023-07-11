. .\0-variables.ps1

## remove failed deployments 
##Get-AzResourceGroupDeployment -resourceGroupName devenvnet | ?{$_.LastRunStatusRunState -ieq "Failed" }
Get-AzImageBuilderTemplate -ResourceGroupName devenvnet | ?{$_.LastRunStatusRunState -ieq "Failed" }  | Remove-AzImageBuilderTemplate

$template=New-AzResourceGroupDeployment -ResourceGroupName $imageResourceGroup -TemplateFile $templateFilePath -Api-Version "2020-02-14" -imageTemplateName $imageTemplateName -svclocation $location

if ($template){
    Invoke-AzResourceAction -ResourceName $imageTemplateName -ResourceGroupName $imageResourceGroup -ResourceType Microsoft.VirtualMachineImages/imageTemplates -ApiVersion "2020-02-14" -Action Run -confirm:$false
}

while ($t=(Get-AzImageBuilderTemplate -ResourceGroupName $imageResourceGroup   -OutVariable p |?{$_.LastRunStatusRunState -ieq "Running"} )) { write-host "$($t|out-string) $(get-date) : running" ; sleep 300 }

.\6-GetError.ps1 -Templatename $imageTemplateName