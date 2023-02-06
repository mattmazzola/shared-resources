$sharedResourceGroupName = "shared"
$sharedRgString = 'klgoyi'
$sharedResourceGroupLocation = "westus3"

echo "PScriptRoot: $PScriptRoot"
$repoRoot = If ('' -eq $PScriptRoot) {
  "$PSScriptRoot/../.."
}
else {
  "."
}

echo "Repo Root: $repoRoot"

Import-Module "$repoRoot/pipelines/scripts/common.psm1" -Force

$sharedResourceNames = Get-ResourceNames $sharedResourceGroupName $sharedRgString

Write-Step "Create Resource Group"
az group create -l $sharedResourceGroupLocation -g $sharedResourceGroupName --query name -o tsv

Write-Step "Provision Resources"
$bicepFile = "$repoRoot/bicep/main.bicep"

az deployment group create `
  -g $sharedResourceGroupName `
  -f $bicepFile `
  --what-if

# az deployment group create `
#   -g $sharedResourceGroupName `
#   -f $bicepFile `
#   --query "properties.provisioningState" `
#   -o tsv
