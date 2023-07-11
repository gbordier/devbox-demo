Param ($templatename)

$failedtemplate = get

if ($failedtemplate.LastRunStatusMessage -match "/resourceGroups/(?<rg>.*?)/providers/" )
{
    get-azstorageAccount -ResourceGroupName $Matches.rg  |Get-AzStorageContainer -Name packerlogs | Get-AzStorageBlob | select -first 1 | Get-AzStorageBlobContent -Destination .\tmp
}