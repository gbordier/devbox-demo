


if (!$identityName){
    $timeInt=$(get-date -UFormat "%s")
    $imageRoleDefName="Azure Image Builder Image Def"+$timeInt
    $identityName="aibIdentity"+$timeInt
    New-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName -Location $location
    
    }
    else {
        
    }
    
    
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
    
    ## create gallery if not existing
    if (! (Get-AzGallery -GalleryName $galleryName -ResourceGroupName $imageResourceGroup  -ErrorAction SilentlyContinue )  )   {
        write-host "$galleryName not found, creating"
        New-AzGallery -GalleryName $galleryName -ResourceGroupName $imageResourceGroup -Location $location
    }

    ## create image definition to push image into
    if (! (Get-AzGalleryImageDefinition -GalleryName $galleryName -ResourceGroupName $imageResourceGroup -Name $imageDefName -ErrorAction SilentlyContinue))
    {
        New-AzGalleryImageDefinition -GalleryName $galleryName -ResourceGroupName $imageResourceGroup -Location $location -Name $imageDefName -OsState generalized -OsType Windows -Publisher 'myCompany' -Offer 'vscodebox' -Sku '1-0-0' -Feature $features -HyperVGeneration "V2"
    }
