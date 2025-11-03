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
$sharedRgString = 'klgoyi'

$sharedResourceNames = Get-ResourceNames $sharedResourceGroupName $sharedRgString

Write-Step "Fetch params from Azure"
$sharedResourceVars = Get-SharedResourceDeploymentVars $sharedResourceGroupName $sharedRgString

$data = [ordered]@{
  "containerAppsEnvResourceId" = $($sharedResourceVars.containerAppsEnvResourceId)
  "registryUrl"                = $($sharedResourceVars.registryUrl)
  "registryUsername"           = $($sharedResourceVars.registryUsername)
  "registryPassword"           = Write-Secret $($sharedResourceVars.registryPassword)
}

Write-Output $sharedResourceVars.containerAppsEnvResourceId

Write-Hash "Data" $data
