Param($templatename)


	. .\0-variables.ps1


	$failedtemplate=Get-AzImageBuilderTemplate -ResourceGroupName $imageresourcegroup |  ?{$_.LastRunStatusRunState -ne "Succeeded"}

	if ($failedtemplate -and $failedtemplate.LastRunStatusMessage -match "/resourceGroups/(?<rg>.*?)/providers/" )
	{
	    $logfile=get-azstorageAccount -ResourceGroupName $Matches.rg  |Get-AzStorageContainer -Name packerlogs | Get-AzStorageBlob | select -first 1 | Get-AzStorageBlobContent  -Destination .\tmp
		write-host "$($logfile|out-string)"
	}
