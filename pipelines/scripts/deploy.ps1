$resourceGroupName = "shared"
$resourceGroupLocation = "westus3"

echo "PScriptRoot: $PScriptRoot"
$scriptRoot = If ('' -eq $PScriptRoot) {
  $PSScriptRoot
} else {
  "."
}

echo "Script Root: $scriptRoot"

Import-Module "$scriptRoot/common.psm1" -Force

Write-Step "Create Resource Group"
az group create -l $resourceGroupLocation -g $resourceGroupName --query name -o tsv

Write-Step "Provision Resources"
az deployment group create `
  -g $resourceGroupName `
  -f ./bicep/main.bicep `
  --query "properties.provisioningState" `
  -o tsv
