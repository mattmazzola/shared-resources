Param([switch]$WhatIf = $True)

echo "PScriptRoot: $PScriptRoot"
$repoRoot = If ('' -eq $PScriptRoot) {
  "$PSScriptRoot/../.."
} Else {
  "."
}

echo "Repo Root: $repoRoot"

Import-Module "$repoRoot/pipelines/scripts/common.psm1" -Force

$inputs = @{
  "WhatIf"= $WhatIf
}

Write-Hash "Inputs" $inputs

$sharedResourceGroupName = "shared"
$sharedResourceGroupLocation = "westus3"

Write-Step "Create Resource Group: $sharedResourceGroupName"
az group create -l $sharedResourceGroupLocation -g $sharedResourceGroupName --query name -o tsv

Write-Step "Provision $sharedResourceGroupName Resources (What-If: $($WhatIf))"
$bicepFile = "$repoRoot/bicep/main.bicep"

if ($WhatIf -eq $True) {
  az deployment group create `
    -g $sharedResourceGroupName `
    -f $bicepFile `
    --what-if
}
else {
  az deployment group create `
    -g $sharedResourceGroupName `
    -f $bicepFile `
    --query "properties.provisioningState" `
    -o tsv
}
