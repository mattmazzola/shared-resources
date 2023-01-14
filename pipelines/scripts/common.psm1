function Write-Step {
    param (
        [Parameter(Mandatory=$true)]
        [string]$text
    )
    
    Write-Output ('=' * $text.Length)
    Write-Output $text
    Write-Output ('=' * $text.Length)
}

function Write-Hash {
    param (
        [Parameter(Mandatory=$true)]
        [string]$text,
        [Parameter(Mandatory=$true)]
        [Object]$hash
    )
    
    Write-Output $text
    Write-Output ('=' * $text.Length)
    Write-Output $hash
}

function Get-ResourceNames {
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$resourceGroupName,
        [Parameter(Mandatory=$true, Position=1)]
        [string]$uniqueRgString
    )

    $resourceNames = [ordered]@{
        containerAppsEnv = "${resourceGroupName}-containerappsenv"
        containerRegistry = "${resourceGroupName}${uniqueRgString}acr"
        cosmosDatabase = "${resourceGroupName}-${uniqueRgString}-cosmos"
        keyVault = "${resourceGroupName}-${uniqueRgString}-keyvault"
        logAnalytics = "${resourceGroupName}-loganalytics"
        sqlDatabas = "${resourceGroupName}-${uniqueRgString}-sql"
    }

    return $resourceNames
}