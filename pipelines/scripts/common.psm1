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

  $variableMatch = $(Get-Content $envFilePath | Select-String -Pattern "$variableName=(.+)")
  $value = $variableMatch.Matches[0].Groups[1].Value

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
