function Write-Step {
  param (
    [Parameter(Mandatory = $true)]
    [string]$text
  )

  Write-Output ('=' * $text.Length)
  Write-Output $text
  Write-Output ('=' * $text.Length)
}

function Write-Hash {
  param (
    [Parameter(Mandatory = $true)]
    [string]$text,
    [Parameter(Mandatory = $true)]
    [Object]$hash
  )

  Write-Output $text
  Write-Output ('=' * $text.Length)
  Write-Output $hash
  Write-Output ""
}

function Write-Secret {
  param (
    [Parameter(Mandatory = $true)]
    [string]$secret,
    [int]$characters = 5
  )

  Write-Output "$($secret.Substring(0, $characters))...$($secret.Substring($secret.Length - $characters))"
}

function Get-ResourceNames {
  param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$resourceGroupName,
    [Parameter(Mandatory = $true, Position = 1)]
    [string]$uniqueRgString
  )

  $resourceNames = [ordered]@{
    containerAppsEnv         = "${resourceGroupName}-containerappsenv"
    containerRegistry        = "${resourceGroupName}${uniqueRgString}acr"
    cosmosDatabase           = "${resourceGroupName}-${uniqueRgString}-cosmos"
    dataFactory              = "${resourceGroupName}-${uniqueRgString}-datafactory"
    keyVault                 = "${resourceGroupName}-${uniqueRgString}-keyvault"
    logAnalytics             = "${resourceGroupName}-loganalytics"
    applicationInsights      = "${resourceGroupName}-appinsights"
    machineLearningWorkspace = "${resourceGroupName}-ml-workspace"
    redis                    = "${resourceGroupName}-${uniqueRgString}-redis"
    sqlDatabase              = "${resourceGroupName}-${uniqueRgString}-sql-db"
    sqlServer                = "${resourceGroupName}-${uniqueRgString}-sql-server"
    serviceBus               = "${resourceGroupName}-${uniqueRgString}-servicebus"
    storageAccount           = "${resourceGroupName}${uniqueRgString}storage"
  }

  return $resourceNames
}

function Get-EnvVarFromFile {
  param (
    [Parameter(Mandatory = $true)]
    [string]$envFilePath,
    [Parameter(Mandatory = $true)]
    [string]$variableName
  )

  $variableMatch = $(Get-Content $envFilePath | Where-Object { $_ -notmatch '^#' } | Select-String -Pattern "$variableName=(.+)")
  if (-not $variableMatch) {
    throw "Variable '$variableName' not found in $envFilePath"
  }
  $value = $variableMatch.Matches[0].Groups[1].Value

  # Strip surrounding quotes if present
  if ($value -match '^["''](.*)["'']$') {
    $value = $matches[1]
  }

  return $value
}

function Get-SharedResourceDeploymentVars {
  param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$resourceGroupName,
    [Parameter(Mandatory = $true, Position = 1)]
    [string]$uniqueRgString
  )

  $sharedResourceNames = Get-ResourceNames $resourceGroupName $uniqueRgString

  $acrJson = $(az acr credential show -n $sharedResourceNames.containerRegistry --query "{ username:username, password:passwords[0].value }" | ConvertFrom-Json)

  $output = [ordered]@{
    containerAppsEnvResourceId = $(az containerapp env show -g $resourceGroupName -n $sharedResourceNames.containerAppsEnv --query "id" -o tsv)
    registryUrl                = $(az acr show -g $resourceGroupName -n $sharedResourceNames.containerRegistry --query "loginServer" -o tsv)
    registryUsername           = $acrJson.username
    registryPassword           = $acrJson.password
  }

  return $output
}

function Get-RepoRoot {
  $callStack = Get-PSCallStack
  # Find the first script in the call stack (excluding this module)
  $callingScript = $callStack | Where-Object { $_.ScriptName -and $_.ScriptName -like "*.ps1" -and $_.ScriptName -notlike "*common.psm1" } | Select-Object -First 1
  if (-not $callingScript) {
    throw "Could not determine calling script path."
  }
  $scriptPath = $callingScript.ScriptName
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
  return @{
    ScriptPath = $scriptPath
    ScriptDir = $scriptDir
    RepoRoot = $repoRoot
  }
}
