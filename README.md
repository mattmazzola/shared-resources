# Shared Resource

Provision resources that will be shared between projects on subscription

## Acquire Permissions

```sh
az login
# Matt Mazzola - Personal
az account set -n 375b0f6d-8ad5-412d-9e11-15d36d14dc63
az acr login --name sharedklgoyiacr
```

## Deploying

```sh
# Quick summary
azd provision --preview

# Detailed ARM what-if
./scripts/what-if.sh
```

## Estimate Costs of Base Resources

$40 per month

## Resource Naming Constraints

- <https://azure.microsoft.com/en-us/pricing>
- <https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules>

## Helpful Commands

1. List Soft-Deleted KeyVaults

```pwsh
az keyvault list-deleted --subscription $subscriptionId --resource-type vault
```

1. Purge Soft-Deleted Key Vault

```pwsh
az keyvault purge --subscription $subscriptionId -n $resourceNames.keyVault
```

1. List User

```pwsh
az ad user show --id ff05dde2-c18e-47fc-9ad2-ebf0c9efb3a0
```

```pwsh
az keyvault purge --subscription $subscriptionId -n $resourceNames.keyVault
```

1. List User

```pwsh
az ad user show --id ff05dde2-c18e-47fc-9ad2-ebf0c9efb3a0
```

1. List Service Principal

```pwsh
az ad sp show --id 0b28d83d-83ac-4bd9-9a24-5003cf8e4796
```

1. Export template of specific resource

```pwsh
$sharedResourceGroupName = "shared"
$resourceGroupLocation = "westus3"
$sharedRgString = "klgoyi"

echo "PScriptRoot: $PScriptRoot"
$repoRoot = If ('' -eq $PScriptRoot) {
  "$PSScriptRoot/../.."
} Else {
  "."
}

echo "Repo Root: $repoRoot"

Import-Module "$repoRoot/pipelines/scripts/common.psm1" -Force

$sharedResourceNames = Get-ResourceNames $sharedResourceGroupName $sharedRgString

$redisId = $(az redis show -g $sharedResourceGroupName -n $sharedResourceNames.redis --query "id" -o tsv)
$sqlServerResourceId = $(az sql server show -g $sharedResourceGroupName -n $sharedResourceNames.sqlServer --query "id" -o tsv)
$sqlDatabaseResourceId = $(az sql db show -g $sharedResourceGroupName --server $sharedResourceNames.sqlServer -n $sharedResourceNames.sqlDatabase --query "id" -o tsv)
$serviceBusResourceId = $(az servicebus namespace show -g $sharedResourceGroupName -n $sharedResourceNames.servicebus --query "id" -o tsv)
$storageResourceId = $(az storage account show -g $sharedResourceGroupName -n $sharedResourceNames.storage --query "id" -o tsv)
$mlWorkspaceResourceId = $(az ml workspace show -g $sharedResourceGroupName -n $sharedResourceNames.machineLearningWorkspace --query "id" -o tsv)

az group export -g $sharedResourceGroupName --resource-ids $redisId > arm-redis.json
az bicep decompile -f arm-redis.json
```

1. Get list of available SQL SKUs for a Region

```pwsh
az sql db list-editions -l westus3 -o table
```

1. Get list of database.bicep files in repos

```pwsh
gci -r -e node_modules "*database.bicep"
```

1. Get list of databases resources in Azure

```pwsh
az sql db list -g $sharedResourceGroupName --server $sharedResourceNames.sqlServer --query "[].{ name:name, maxSizeBytes:maxSizeBytes }" -o table
```
