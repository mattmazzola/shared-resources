Param([switch]$WhatIf = $True)

$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path $scriptPath

# Find repo root by searching upward for README.md
$currentDir = $scriptDir
$repoRoot = $null
while ($currentDir -and -not $repoRoot) {
    if (Test-Path (Join-Path $currentDir "README.md")) {
        $repoRoot = $currentDir
    } else {
        $currentDir = Split-Path $currentDir
    }
}
if (-not $repoRoot) {
    throw "Could not find repo root (no README.md found in parent directories)."
}

echo "Script Path: $scriptPath"
echo "Script Dir: $scriptDir"
echo "Repo Root: $repoRoot"

$commonModulePath = Resolve-Path "$repoRoot/pipelines/scripts/common.psm1"
echo "Common Module Path: $commonModulePath"
Import-Module $commonModulePath -Force

$inputs = @{
  "WhatIf"= $WhatIf
}

Write-Hash "Inputs" $inputs

$sharedResourceGroupName = "shared"
$sharedResourceGroupLocation = "westus3"

Write-Step "Create Resource Group: $sharedResourceGroupName"
az group create -l $sharedResourceGroupLocation -g $sharedResourceGroupName --query name -o tsv

Write-Step "Provision $sharedResourceGroupName Resources (What-If: $($WhatIf))"
$bicepFile = "$repoRoot/infra/main.bicep"

if ($WhatIf -eq $True) {
  az deployment group create `
    -g $sharedResourceGroupName `
    -f $bicepFile `
    --parameters sqlServerAdminPassword=$env:SQL_SERVER_ADMIN_PASSWORD `
    --what-if
}
else {
  az deployment group create `
    -g $sharedResourceGroupName `
    -f $bicepFile `
    --parameters sqlServerAdminPassword=$env:SQL_SERVER_ADMIN_PASSWORD `
    --query "properties.provisioningState" `
    -o tsv
}
