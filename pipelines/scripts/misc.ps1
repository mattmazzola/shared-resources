$resourceGroupName = "shared"
$resourceGroupLocation = "westus3"
$uniqueRgString = "klgoyi"

echo "PScriptRoot: $PScriptRoot"
$scriptRoot = If ('' -eq $PScriptRoot) {
  $PSScriptRoot
} else {
  "."
}

echo "Script Root: $scriptRoot"

Import-Module "$scriptRoot/common.psm1" -Force

az deployment group create `
  -g $resourceGroupName `
  -f ./bicep/main.bicep `
  --what-if
