$resourceGroupName = "shared"
$resourceGroupLocation = "westus3"
$uniqueRgString = "klgoyi"

Import-Module "$PSScriptRoot/common.psm1" -Force

az deployment group create `
  -g $resourceGroupName `
  -f ./bicep/main.bicep `
  --what-if
