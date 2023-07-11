Param ([switch] $force)

. .\0-variables.ps1

## "Az.ManagedServiceIdentity",

if (!$identityNameResourceId -and -not $force) {
    $identityNameResourceId=$(Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName).Id 
    $identityNamePrincipalId=$(Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName).PrincipalId
}

if (!$identityNameResourceId) {
    Write-Error "no managed identity, create one"
}
