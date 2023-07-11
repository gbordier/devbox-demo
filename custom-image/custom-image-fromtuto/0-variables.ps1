##variables.ps1

$resourcegroupname="devenvnet"
$subscriptionID=$currentAzContext.Subscription.Id
$imageResourceGroup=$resourcegroupname
$location="westeurope"
$runOutputName="aibCustWinManImg01"

$imageTemplateName="vscodeWinTemplate"
$identityName="MI-DEV-TEST"

## mandatory for devbox images
$SecurityType = @{Name='SecurityType';Value='TrustedLaunch'}  
$features = @($SecurityType)


$galleryName= "devboxGallery-WE"

# Image definition name
$imageDefName ="vscodeImageDef"

# Additional replication region
$replRegion2="northeurope"