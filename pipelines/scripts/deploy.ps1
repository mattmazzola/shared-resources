Param([switch]$RealDeploy)

$inputs = @{
  "RealDeploy"= $RealDeploy
}

Write-Hash "Inputs" $inputs

$sharedResourceGroupName = "shared"
$sharedRgString = 'klgoyi'
$sharedResourceGroupLocation = "westus3"

echo "PScriptRoot: $PScriptRoot"
$repoRoot = If ('' -eq $PScriptRoot) {
  "$PSScriptRoot/../.."
} Else {
  "."
}

echo "Repo Root: $repoRoot"

Import-Module "$repoRoot/pipelines/scripts/common.psm1" -Force

$sharedResourceNames = Get-ResourceNames $sharedResourceGroupName $sharedRgString

Write-Step "Create Resource Group"
az group create -l $sharedResourceGroupLocation -g $sharedResourceGroupName --query name -o tsv

Write-Step "Provision $sharedResourceGroupName Resources"
$bicepFile = "$repoRoot/bicep/main.bicep"

if ($RealDeploy -eq $True) {
  az deployment group create `
    -g $sharedResourceGroupName `
    -f $bicepFile `
    --query "properties.provisioningState" `
    -o tsv
}
else {
  az deployment group create `
    -g $sharedResourceGroupName `
    -f $bicepFile `
    --what-if
}
