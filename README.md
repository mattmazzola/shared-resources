# Shared Resource

Provision resources that will be shared between projects on subscription

## Resource Naming Constraints

- <https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules>

## Helpful Commands

1. List Soft-Deleted KeyVaults

```powershell
az keyvault list-deleted --subscription $subscriptionId --resource-type vault
```

1. Purge Soft-Deleted Key Vault

```powershell
az keyvault purge --subscription $subscriptionId -n $resourceNames.keyVault
```

1. Export template of specific resource

```powershell
$sqlServerResourceId = $(az sql server show -g $resourceGroupName -n $resourceNames.sqlServer --query "id" -o tsv)
$sqlDatabaseResourceId = $(az sql db show -g $resourceGroupName --server $resourceNames.sqlServer -n $resourceNames.sqlDatabase --query "id" -o tsv)

az group export -g $resourceGroupName --resource-ids $sqlServerResourceId $sqlDatabaseResourceId > arm-db.json
az bicep decompile -f arm-db.json
```

1. Get list of available SQL SKUs for a Region

```powershell
az sql db list-editions -l westus3 -o table
```