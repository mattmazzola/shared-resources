$resourceGroupName = "shared"
$resourceGroupLocation = "westus3"
$uniqueRgString = "klgoyi"

Import-Module "$PSScriptRoot/common.psm1" -Force

$resourceNames = Get-ResourceNames $resourceGroupName $uniqueRgString

