. .\0-variables.ps1

## cleanup previous runs
get-azimageBuilderTemplate -ResourceGroupName $imageResourceGroup|?{$_.LastRunStatusRunState -ne "Succeeded"} | Remove-AzImageBuilderTemplate

$run=az deployment group create --name devboxtest --resource-group $imageResourceGroup --template-file deploy.bicep

if ($run -and $run -imatch "Microsoft.VirtualMachineImages/imageTemplates/(?<template>.*?)\""")
{
	$template=($Matches | select -first 1 ).template

	"{'template' : '$template' }" | set-content .\status.json
	while ($t=(Get-AzImageBuilderTemplate -ResourceGroupName $imageResourceGroup  |?{$_.LastRunStatusRunState -ieq "Running"} )) {
		 write-host "$($t|out-string) $(get-date) : running" ; sleep 300 
	}
	$failedtemplate=Get-AzImageBuilderTemplate -ImageTemplateName $Matches.template -ResourceGroupName $imageresourcegroup |  ?{$_.LastRunStatusRunState -ne "Succeeded"}

	if ($failedtemplate){
		.\6-GetError.ps1 -Templatename $failedtemplate
	}
	else {
		write-host "successfully deployed template $temaplte " 
	}

}

